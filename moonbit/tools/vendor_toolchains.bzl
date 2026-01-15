"""MoonBit toolchain vendoring using Bazel repository rules"""

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

# Try to use enhanced registry first, fall back to legacy
try:
    load("//moonbit/checksums:registry_v2.bzl", 
         "get_moonbit_checksum_v2", 
         "get_moonbit_info_v2", 
         "get_github_repo_v2",
         "get_latest_moonbit_version_v2")
    
    # Alias enhanced functions as primary
    get_moonbit_checksum = get_moonbit_checksum_v2
    get_moonbit_info = get_moonbit_info_v2
    get_github_repo = get_github_repo_v2
    get_latest_moonbit_version = get_latest_moonbit_version_v2
    
    # Enable new checksum updater features
    USE_NEW_CHECKSUM_UPDATER = True
except:
    # Fall back to legacy registry
    load("//moonbit/checksums:registry.bzl", 
         "get_moonbit_checksum", 
         "get_moonbit_info", 
         "get_github_repo",
         "get_latest_moonbit_version")
    
    # Legacy mode
    USE_NEW_CHECKSUM_UPDATER = False

# Configuration option for new checksum updater
# Set to True to enable enhanced features when available
USE_NEW_CHECKSUM_UPDATER = False

def _construct_moonbit_download_url(version, platform, tool_info):
    """Build download URL for MoonBit tool"""
    
    # Use the actual CLI URL structure
    url_suffix = tool_info.get("url_suffix")
    if not url_suffix:
        return None
    
    # Build the URL using the actual CLI structure
    return "https://cli.moonbitlang.com/binaries/{}/{}'.format(version, url_suffix)

def _construct_core_download_url(version):
    """Build download URL for MoonBit core"""
    
    # Use the actual CLI URL structure for cores
    return "https://cli.moonbitlang.com/cores/core-{}.tar.gz".format(version)

def _vendor_moonbit_toolchain_impl(repository_ctx):
    """Download MoonBit toolchain using Bazel repository rules
    
    This reuses secure download infrastructure to download MoonBit
    into Bazel's repository cache.
    """
    
    # Get the latest MoonBit version
    latest_version = get_latest_moonbit_version(repository_ctx)
    if not latest_version:
        fail("No MoonBit versions found in checksum registry")
    
    # Determine platform
    platform = repository_ctx.platform
    
    # Get tool info for this platform
    tool_info = get_moonbit_info(repository_ctx, latest_version, platform)
    if not tool_info:
        fail("MoonBit not available for platform: {}".format(platform))
    
    # Get checksum
    checksum = get_moonbit_checksum(repository_ctx, latest_version, platform)
    if not checksum:
        fail("Checksum not found for MoonBit version '{}' platform '{}'".format(latest_version, platform))
    
    # Build download URL
    download_url = _construct_moonbit_download_url(latest_version, platform, tool_info)
    if not download_url:
        fail("Could not construct download URL for platform: {}".format(platform))
    
    # Download the toolchain archive
    archive_file = repository_ctx.download(
        url = download_url,
        sha256 = checksum,
        strip_prefix = tool_info.get("strip_prefix", "moonbit-")
    )
    
    # Extract the moon executable
    moon_executable = archive_file + "/moon"
    
    # Download the core library
    core_url = _construct_core_download_url(latest_version)
    core_checksum = "bf12dce0a92d84911e0d30cb74ac73f80d03a89f0933a4bda87e2f6647a00887"  # Core checksum
    
    core_archive = repository_ctx.download(
        url = core_url,
        sha256 = core_checksum
    )
    
    # Extract core library
    core_dir = archive_file + "/core"
    
    return struct(
        moon = moon_executable,
        version = latest_version,
        platform = platform,
        core = core_dir
    )

def vendor_moonbit_toolchain(
    name = "moonbit_toolchain",
    version = None,
    platforms = None,
):
    """Vendor MoonBit toolchain using Bazel repository rules
    
    Args:
        name: Name for the toolchain repository
        version: Specific MoonBit version (None for latest)
        platforms: List of platforms to support (None for all)
        
    Example:
        vendor_moonbit_toolchain(
            name = "moonbit_tools",
            platforms = ["darwin_arm64", "linux_amd64"],
        )
    """
    native.repository_rule(
        name = name,
        implementation = _vendor_moonbit_toolchain_impl,
        attrs = {},
        local = False,
    )
