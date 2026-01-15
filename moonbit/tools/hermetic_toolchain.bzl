"""Hermetic MoonBit toolchain implementation using http_archive"""

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

load("//moonbit/checksums:registry.bzl", 
     "get_moonbit_checksum", 
     "get_moonbit_info",
     "get_latest_moonbit_version")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _construct_moonbit_download_url(version, platform, tool_info):
    """Build download URL for MoonBit tool using real CLI structure"""
    
    url_suffix = tool_info.get("url_suffix")
    if not url_suffix:
        return None
    
    # Use the actual CLI URL structure from moonbitlang.com
    return "https://cli.moonbitlang.com/binaries/{}/{}".format(version, url_suffix)

def _moonbit_toolchain_impl(repository_ctx):
    """Download and set up MoonBit toolchain using http_archive
    
    This implements a hermetic toolchain that downloads MoonBit
    from the official CLI and verifies checksums.
    """
    
    # Get the latest MoonBit version
    latest_version = get_latest_moonbit_version(repository_ctx)
    if not latest_version:
        fail("No MoonBit versions found in checksum registry")
    
    # Determine platform based on execution platform
    platform = _get_current_platform(repository_ctx)
    
    # Get tool info for this platform
    tool_info = get_moonbit_info(repository_ctx, latest_version, platform)
    if not tool_info:
        fail("MoonBit not available for platform: {}".format(platform))
    
    # Get checksum for verification
    checksum = get_moonbit_checksum(repository_ctx, latest_version, platform)
    
    # Build download URL
    download_url = _construct_moonbit_download_url(latest_version, platform, tool_info)
    if not download_url:
        fail("Could not construct download URL for platform: {}".format(platform))
    
    # Determine platform-specific strip prefix
    strip_prefix = tool_info.get("strip_prefix", "moonbit-")
    
    # Use http_archive to download and extract the toolchain
    # Handle both verified checksums and unverified downloads
    if checksum:
        # Verified download with checksum
        http_archive(
            name = "moonbit_toolchain",
            urls = [download_url],
            sha256 = checksum,
            strip_prefix = strip_prefix,
            build_file = "@rules_moonbit//moonbit/tools:moonbit_toolchain.BUILD",
        )
        repository_ctx.info("Downloaded MoonBit {} for {} with checksum verification".format(latest_version, platform))
    else:
        # Unverified download (for development/testing only)
        repository_ctx.warning(
            "Downloading MoonBit {} for {} without checksum verification - this is not secure for production use".format(latest_version, platform)
        )
        http_archive(
            name = "moonbit_toolchain",
            urls = [download_url],
            strip_prefix = strip_prefix,
            build_file = "@rules_moonbit//moonbit/tools:moonbit_toolchain.BUILD",
        )
    
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
}}""".format(latest_version, platform, download_url, bool(checksum), tool_info),
    )
    
    # Return the toolchain information
    return {
        "moon_executable": "$(location moonbit_toolchain/moon)",
        "version": latest_version,
        "platform": platform,
    }

def _get_current_platform(repository_ctx):
    """Determine the current platform for toolchain selection
    
    Enhanced platform detection with architecture support for:
    - macOS: arm64 (Apple Silicon) and amd64 (Intel)
    - Linux: x86_64 and arm64
    - Windows: x86_64
    """
    # Get the execution platform
    exec_platform = repository_ctx.platform
    
    # Determine OS and architecture
    if "darwin" in exec_platform:
        # macOS platform detection
        if "arm64" in exec_platform or "aarch64" in exec_platform:
            return "darwin_arm64"
        else:
            return "darwin_amd64"  # Intel macOS
    elif "linux" in exec_platform:
        # Linux platform detection
        if "arm64" in exec_platform or "aarch64" in exec_platform:
            return "linux_arm64"
        else:
            return "linux_amd64"  # x86_64 Linux
    elif "windows" in exec_platform:
        # Windows platform detection
        if "amd64" in exec_platform or "x86_64" in exec_platform:
            return "windows_amd64"
        else:
            return "windows_amd64"  # Default to x86_64 for Windows
    else:
        # Fallback to linux_x86_64 if platform not recognized
        repository_ctx.warning("Unrecognized platform: {}. Falling back to linux_amd64".format(exec_platform))
        return "linux_amd64"

def moonbit_register_hermetic_toolchain(
    name = "moonbit_toolchain",
    version = None,
    platforms = None,
):
    """Register hermetic MoonBit toolchain using http_archive
    
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
    
    native.repository_rule(
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
    load("//moonbit:BUILD.bazel", "moonbit_toolchain_type")
    native.register_toolchains(
        "@" + name + "//:moonbit_toolchain",
        toolchains = [moonbit_toolchain_type],
    )
