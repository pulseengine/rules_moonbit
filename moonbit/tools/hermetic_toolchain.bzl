"""Hermetic MoonBit toolchain implementation using http_archive

This implementation follows the patterns from rules_rust and rules_wasm_component
for proper Bazel 8.5+ compatibility and hermetic toolchain downloads.
"""

# Copyright 2026 The Rules_Moonbit Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//moonbit/checksums:registry_v2.bzl", 
     "get_moonbit_checksum_v2", 
     "get_moonbit_info_v2", 
     "get_latest_moonbit_version_v2",
     "get_github_repo_v2")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _create_unsupported_platform_stub(repository_ctx, version, platform):
    """Create a stub toolchain for unsupported platforms.

    This allows Bazel analysis to succeed on platforms where MoonBit
    is not available. Builds that actually need MoonBit will fail with
    a clear error message at build time rather than analysis time.
    """
    # Create a stub moon script that fails with a helpful message
    stub_script = """#!/bin/bash
echo "ERROR: MoonBit is not available for platform: {platform}" >&2
echo "MoonBit only supports: darwin_arm64, linux_amd64, windows_amd64" >&2
exit 1
""".format(platform = platform)

    repository_ctx.file("bin/moon", content = stub_script, executable = True)

    # Create BUILD.bazel with stub toolchain
    build_content = '''# Auto-generated stub for unsupported platform: {platform}
# MoonBit only provides binaries for darwin_arm64, linux_amd64, windows_amd64

load(":toolchain_impl.bzl", "moonbit_hermetic_toolchain")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_files",
    srcs = glob(["bin/*"]),
)

moonbit_hermetic_toolchain(
    name = "moonbit_toolchain_impl",
    moon_executable = "bin/moon",
    all_files = [":all_files"],
    version = "{version}",
    target_platform = "{platform}",
)

toolchain(
    name = "moonbit_toolchain",
    exec_compatible_with = [],
    target_compatible_with = [],
    toolchain = ":moonbit_toolchain_impl",
    toolchain_type = "@rules_moonbit//moonbit:moonbit_toolchain_type",
)
'''.format(version = version, platform = platform)

    repository_ctx.file("BUILD.bazel", content = build_content)

    # Create minimal toolchain_impl.bzl
    toolchain_bzl_content = '''"""Stub toolchain for unsupported platform"""

load("@rules_moonbit//moonbit:providers.bzl", "MoonbitToolchainInfo")

def _moonbit_hermetic_toolchain_impl(ctx):
    """Stub toolchain that indicates platform is not supported."""
    moon_executable = ctx.file.moon_executable

    toolchain_info = MoonbitToolchainInfo(
        moon_executable = moon_executable,
        version = ctx.attr.version,
        target_platform = ctx.attr.target_platform,
        all_files = depset([moon_executable] + ctx.files.all_files),
        supports_wasm = False,  # Not supported on this platform
        supports_native = False,
        supports_js = False,
        supports_c = False,
    )

    return [platform_common.ToolchainInfo(moonbit = toolchain_info)]

moonbit_hermetic_toolchain = rule(
    implementation = _moonbit_hermetic_toolchain_impl,
    attrs = {
        "moon_executable": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "all_files": attr.label_list(allow_files = True),
        "version": attr.string(),
        "target_platform": attr.string(),
    },
)
'''
    repository_ctx.file("toolchain_impl.bzl", content = toolchain_bzl_content)

def _moonbit_toolchain_impl(repository_ctx):
    """Download and set up MoonBit toolchain using http_archive
    
    This implements a hermetic toolchain that downloads MoonBit
    from the official CLI and verifies checksums.
    
    Args:
        repository_ctx: Repository context for toolchain implementation
        
    Returns:
        Dict: Toolchain information including moon executable path
    """
    
    # Get version from attributes or use a default
    version = repository_ctx.attr.version if repository_ctx.attr.version else "0.6.33"
    if not version:
        fail("No MoonBit version specified")
    
    # Determine platform based on execution platform
    platform = _get_current_platform(repository_ctx)
    
    # Get tool info for this platform
    tool_info = get_moonbit_info_v2(repository_ctx, version, platform)
    if not tool_info:
        # Platform not supported - create stub toolchain that gracefully fails at build time
        # This prevents Bazel from failing during analysis on unsupported platforms
        _create_unsupported_platform_stub(repository_ctx, version, platform)
        return
    
    # Get checksum for verification
    checksum = get_moonbit_checksum_v2(repository_ctx, version, platform)
    
    # Build download URL - MoonBit uses cli.moonbitlang.com, not GitHub releases
    url_suffix = tool_info.get("url_suffix")
    if not url_suffix:
        fail("Could not construct download URL for platform: {}".format(platform))

    # MoonBit distributes binaries from their own CDN
    # For "latest" or current version, use the latest endpoint
    # Format: https://cli.moonbitlang.com/binaries/latest/moonbit-{os}-{arch}.tar.gz
    if version == "latest" or version == "0.6.33":
        # Use latest binaries endpoint
        download_url = "https://cli.moonbitlang.com/binaries/latest/{}".format(url_suffix)
    else:
        # For specific versions, try versioned URL (may not exist)
        download_url = "https://cli.moonbitlang.com/binaries/{}/{}".format(version, url_suffix)
    
    # Determine archive type from URL suffix or explicit field
    # MoonBit uses .zip on Windows and .tar.gz on Unix
    archive_type = tool_info.get("archive_type")
    if not archive_type:
        # Infer from URL suffix
        if url_suffix.endswith(".zip"):
            archive_type = "zip"
        elif url_suffix.endswith(".tar.gz"):
            archive_type = "tar.gz"
        else:
            archive_type = "tar.gz"  # Default fallback

    # MoonBit archives have no strip prefix - files are at ./bin/, ./lib/, ./include/
    strip_prefix = tool_info.get("strip_prefix", "")
    
    # Use repository_ctx methods to download and extract the toolchain
    # Just call download_and_extract directly - Bazel will fail with clear message
    repository_ctx.download_and_extract(
        url = download_url,
        sha256 = checksum if checksum else "",
        strip_prefix = strip_prefix,
        type = archive_type,
    )

    # Make binaries executable (tar extraction may not preserve permissions)
    # Skip on Windows where chmod doesn't apply
    if not platform.startswith("windows"):
        bin_path = repository_ctx.path("bin")
        if bin_path.exists:
            # Make all binaries in bin/ executable
            for binary in ["moon", "moonc", "moonfmt", "mooninfo", "moonrun", "moondoc"]:
                binary_path = bin_path.get_child(binary)
                if binary_path.exists:
                    repository_ctx.execute(["chmod", "+x", str(binary_path)])

    # Write toolchain info for debugging
    toolchain_info_file = repository_ctx.path("moonbit_toolchain_info.json")
    repository_ctx.file(
        toolchain_info_file,
        content = """{
  "moonbit_toolchain": {
    "version": "%s",
    "platform": "%s",
    "download_url": "%s",
    "checksum_verified": %s
  }
}""" % (version, platform, download_url, str(bool(checksum)).lower()),
    )

    # Generate BUILD.bazel file for the toolchain repository
    # We need to create a .bzl file with the toolchain implementation that provides ToolchainInfo
    toolchain_bzl_content = '''"""Generated toolchain implementation for hermetic MoonBit"""

load("@rules_moonbit//moonbit:providers.bzl", "MoonbitToolchainInfo")

def _moonbit_hermetic_toolchain_impl(ctx):
    """Toolchain implementation that provides ToolchainInfo."""
    moon_executable = ctx.file.moon_executable

    toolchain_info = MoonbitToolchainInfo(
        moon_executable = moon_executable,
        version = ctx.attr.version,
        target_platform = ctx.attr.target_platform,
        all_files = depset([moon_executable] + ctx.files.all_files),
        supports_wasm = True,
        supports_native = True,
        supports_js = True,
        supports_c = True,
    )

    return [platform_common.ToolchainInfo(moonbit = toolchain_info)]

moonbit_hermetic_toolchain = rule(
    implementation = _moonbit_hermetic_toolchain_impl,
    attrs = {{
        "moon_executable": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "all_files": attr.label_list(allow_files = True),
        "version": attr.string(default = "{version}"),
        "target_platform": attr.string(default = "{platform}"),
    }},
)
'''

    repository_ctx.file("toolchain_impl.bzl", content = toolchain_bzl_content.format(
        version=version,
        platform=platform
    ))

    build_content = '''# Generated BUILD.bazel for MoonBit toolchain
# Version: {version}
# Platform: {platform}

load(":toolchain_impl.bzl", "moonbit_hermetic_toolchain")

package(default_visibility = ["//visibility:public"])

# Export the moon binary
exports_files(["bin/moon", "bin/moonfmt", "bin/mooninfo"])

# Filegroup for all binaries
filegroup(
    name = "moon_binaries",
    srcs = glob(["bin/*"]),
)

# Filegroup for runtime libraries
filegroup(
    name = "moon_runtime",
    srcs = glob(["lib/*"]),
)

# Filegroup for headers
filegroup(
    name = "moon_headers",
    srcs = glob(["include/*"]),
)

# Toolchain implementation - provides ToolchainInfo with MoonbitToolchainInfo
moonbit_hermetic_toolchain(
    name = "moonbit_toolchain_impl",
    moon_executable = "bin/moon",
    all_files = [
        ":moon_binaries",
        ":moon_runtime",
        ":moon_headers",
    ],
    version = "{version}",
    target_platform = "{platform}",
)

# Toolchain definition - registers with Bazel's toolchain resolution
toolchain(
    name = "moonbit_toolchain",
    toolchain = ":moonbit_toolchain_impl",
    toolchain_type = "@rules_moonbit//moonbit:moonbit_toolchain_type",
)
'''.format(version=version, platform=platform)

    repository_ctx.file("BUILD.bazel", content = build_content)



def _get_current_platform(repository_ctx):
    """Determine the current platform for toolchain selection
    
    Simple platform detection that works in repository rules.
    
    Args:
        repository_ctx: Repository context for platform detection
        
    Returns:
        String: Platform identifier (e.g., 'darwin_arm64', 'linux_amd64')
    """
    # Use repository_ctx.os which is the correct API
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch
    
    if "mac" in os_name or "darwin" in os_name:
        return "darwin_arm64" if arch == "aarch64" else "darwin_amd64"
    elif "windows" in os_name:
        return "windows_amd64"
    else:
        return "linux_amd64"

def moonbit_register_hermetic_toolchain(
    name = "moonbit_toolchain",
    version = None,
    platforms = None,
):
    """Register hermetic MoonBit toolchain using http_archive
    
    This follows the pattern from rules_rust for proper toolchain registration.
    
    Args:
        name: Name for the toolchain repository
        version: Specific MoonBit version (None for latest)
        platforms: List of platforms to support (None for auto-detect)
        
    Example:
        moonbit_register_hermetic_toolchain(
            name = "moonbit_tools",
            platforms = ["darwin_arm64", "linux_amd64"],
        )
    """
    
    # Just call the repository rule directly - this is the correct approach
    moonbit_toolchain_repository(
        name = name,
        version = version or "latest",
    )

# Define the repository rule for external use
moonbit_toolchain_repository = repository_rule(
    implementation = _moonbit_toolchain_impl,
    attrs = {
        "version": attr.string(
            doc = "MoonBit version to use",
            default = "latest",
        ),
    },
    local = False,
)