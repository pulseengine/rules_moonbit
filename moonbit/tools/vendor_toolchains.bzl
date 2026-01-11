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

load("//moonbit/checksums:registry.bzl", 
     "get_moonbit_checksum", 
     "get_moonbit_info", 
     "get_github_repo",
     "get_latest_moonbit_version")

def _construct_moonbit_download_url(tool_name, version, platform, tool_info, github_mirror = "https://github.com"):
    """Build download URL for MoonBit tool"""
    
    github_repo = get_github_repo()
    if not github_repo:
        fail("GitHub repository not found for MoonBit")
    
    url_suffix = tool_info.get("url_suffix")
    if not url_suffix:
        fail("URL suffix not found for MoonBit version '{}' platform '{}'".format(version, platform))
    
    # Build the URL using GitHub releases pattern
    return "{mirror}/{github_repo}/releases/download/v{version}/{suffix}".format(
        mirror = github_mirror,
        github_repo = github_repo,
        version = version,
        suffix = url_suffix,
    )

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
    download_url = _construct_moonbit_download_url(
        "moonbit", latest_version, platform, tool_info
    )
    
    # Download the toolchain archive
    archive_file = repository_ctx.download(
        url = download_url,
        sha256 = checksum,
        strip_prefix = tool_info.get("strip_prefix", "moonbit-")
    )
    
    # Extract the moon executable
    moon_executable = archive_file + "/moon"
    
    return struct(
        moon = moon_executable,
        version = latest_version,
        platform = platform,
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
