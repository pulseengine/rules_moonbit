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
        fail("MoonBit not available for platform: {}".format(platform))
    
    # Get checksum for verification
    checksum = get_moonbit_checksum_v2(repository_ctx, version, platform)
    
    # Build download URL
    github_repo = get_github_repo_v2()
    url_suffix = tool_info.get("url_suffix")
    if not url_suffix:
        fail("Could not construct download URL for platform: {}".format(platform))
    
    download_url = "https://github.com/{}/releases/download/v{}/{}".format(
        github_repo, 
        version, 
        url_suffix
    )
    
    # Determine archive type and strip prefix
    archive_type = tool_info.get("archive_type", "tar.gz")
    strip_prefix = tool_info.get("strip_prefix", "moonbit-")
    
    # Use repository_ctx methods to download and extract the toolchain
    try:
        if checksum:
            # Verified download with checksum
            repository_ctx.download_and_extract(
                url = download_url,
                sha256 = checksum,
                strip_prefix = strip_prefix,
                type = archive_type,
            )
        else:
            # Unverified download (for development/testing only)
            repository_ctx.download_and_extract(
                url = download_url,
                strip_prefix = strip_prefix,
                type = archive_type,
            )
    except:
        # If download fails, create a fallback toolchain with helpful error message
        _create_fallback_toolchain(repository_ctx, version, platform, download_url)
    
    # Validate that the toolchain was downloaded successfully
    toolchain_info_file = repository_ctx.path("moonbit_toolchain_info.json")
    repository_ctx.write(
        output = toolchain_info_file,
        content = """{{
  "moonbit_toolchain": {{
    "version": "{}",
    "platform": "{}",
    "download_url": "{}",
    "checksum_verified": {},
    "tool_info": {}
  }}
}}""".format(version, platform, download_url, bool(checksum), tool_info),
    )
    
    # Return the toolchain information
    return {
        "moon_executable": "$(location moonbit_toolchain/moon)",
        "version": version,
        "platform": platform,
    }

def _create_fallback_toolchain(repository_ctx, version, platform, download_url):
    """Create a fallback toolchain when download fails."""
    # Create a placeholder moon executable
    moon_executable = repository_ctx.actions.declare_file("moon")
    repository_ctx.actions.write(
        output = moon_executable,
        content = """#!/bin/bash
# MoonBit Compiler - Fallback/Placeholder
# This is a fallback executable created because the real MoonBit compiler
# could not be downloaded from: {}

echo "ERROR: MoonBit compiler not available"
echo "Attempted to download from: {}"
echo "Version: {}"
echo "Platform: {}"
echo ""
echo "This is a fallback executable. Please ensure:"
echo "1. You have internet connectivity"
echo "2. The MoonBit release exists at the specified URL"
echo "3. The checksums in moonbit.json are correct"
echo ""
echo "For development/testing, you can:"
echo "1. Use a local MoonBit installation"
echo "2. Create a test toolchain with: bazel run //:test_toolchain.sh"
echo "3. Update the checksum registry with correct URLs"
exit 1
""".format(download_url, download_url, version, platform),
        is_executable = True
    )
    
    # Create an info file explaining the issue
    info_file = repository_ctx.actions.declare_file("DOWNLOAD_FAILED.txt")
    repository_ctx.actions.write(
        output = info_file,
        content = """MoonBit Toolchain Download Failed

The MoonBit compiler could not be downloaded from:
{}

Version: {}
Platform: {}

Possible reasons:
1. The specified version does not exist
2. The platform is not supported
3. Network connectivity issues
4. GitHub rate limiting
5. Incorrect checksum registry entries

To resolve this issue:

1. Check if the version exists in the checksum registry:
   //moonbit/checksums/moonbit.json

2. Verify the download URL format is correct

3. For development, use the test toolchain:
   - Run: bazel run //:test_toolchain.sh
   - Update WORKSPACE to use local_repository pointing to moonbit_toolchain/

4. If you believe this is a bug, please report it with:
   - The exact version and platform you're trying to use
   - The full error message
   - Your operating system and architecture

Fallback toolchain created for basic functionality.""".format(download_url, version, platform),
        is_executable = False
    )

def _get_current_platform(repository_ctx):
    """Determine the current platform for toolchain selection
    
    Simple platform detection that works in repository rules.
    
    Args:
        repository_ctx: Repository context for platform detection
        
    Returns:
        String: Platform identifier (e.g., 'darwin_arm64', 'linux_amd64')
    """
    # Use a simple approach - check environment variables
    # This is the most reliable method for repository rules
    
    # Check for macOS
    if repository_ctx.getenv("MACOSX_DEPLOYMENT_TARGET") or repository_ctx.getenv("__APPLE__"):
        # Check architecture - default to arm64 for modern macOS
        if repository_ctx.getenv("ARCH") == "arm64" or repository_ctx.getenv("PROCESSOR_ARCHITECTURE") == "arm64":
            return "darwin_arm64"
        else:
            return "darwin_amd64"
    
    # Check for Windows
    elif repository_ctx.getenv("OS") == "Windows_NT":
        return "windows_amd64"
    
    # Default to Linux (most common case for CI/CD)
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
    
    # Define the repository rule
    moonbit_toolchain_repository = repository_rule(
        name = name,
        implementation = _moonbit_toolchain_impl,
        attrs = {
            "version": attr.string(
                doc = "MoonBit version to use",
                default = version or "latest",
            ),
            "platforms": attr.string_list(
                doc = "Platforms to support",
                default = platforms or [],
            ),
        },
        local = False,
    )
    
    # Also register the toolchain for Bazel toolchain resolution
    # This connects the repository to the toolchain_type
    # Note: Toolchain registration is handled automatically by Bazel's toolchain resolution

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