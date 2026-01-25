"""MoonBit checksum registry API"""

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

"""Centralized checksum registry API for MoonBit toolchain

This module provides a unified API for accessing MoonBit tool checksums.
"""

def _load_moonbit_checksums_from_json(repository_ctx):
    """Load checksums for MoonBit from JSON file
    
    This is the ONLY source of truth for MoonBit checksums.
    JSON files should be generated and maintained with verified checksums.
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        Dict: MoonBit tool data from JSON file
        
    Raises:
        fail: If JSON file not found
    """
    json_file = repository_ctx.path(Label("@rules_moonbit//moonbit/checksums:moonbit.json"))
    if not json_file.exists:
        fail("MoonBit checksums not found: //moonbit/checksums/moonbit.json\n" +
             "This file should contain verified checksums for MoonBit releases.")
    
    content = repository_ctx.read(json_file)
    return json.decode(content)

def get_moonbit_checksum(repository_ctx, version, platform):
    """Get verified checksum from centralized registry
    
    Args:
        repository_ctx: Repository context for file operations
        version: MoonBit version string (e.g., '0.6.33')
        platform: Platform string (e.g., 'darwin_arm64', 'linux_amd64')
        
    Returns:
        String: SHA256 checksum, or None if not found or placeholder
    """
    moonbit_data = _load_moonbit_checksums_from_json(repository_ctx)
    
    versions = moonbit_data.get("versions", {})
    version_data = versions.get(version, {})
    platforms = version_data.get("platforms", {})
    platform_data = platforms.get(platform, {})
    
    checksum = platform_data.get("sha256")
    status = platform_data.get("status", "verified")
    
    # Skip placeholder checksums and warn user
    if status == "placeholder":
        # buildifier: disable=print
        print(
            "WARNING: Placeholder checksum for MoonBit {} on {} - checksum verification skipped. ".format(version, platform) +
            "Please update moonbit.json with the actual checksum from official releases."
        )
        return None

    # Skip TODO checksums
    if checksum == "TODO":
        # buildifier: disable=print
        print(
            "WARNING: Checksum not available for MoonBit {} on {} - download verification disabled.".format(version, platform)
        )
        return None
    
    return checksum

def get_moonbit_info(repository_ctx, version, platform):
    """Get complete MoonBit information from centralized registry
    
    Args:
        repository_ctx: Repository context for file operations
        version: MoonBit version string
        platform: Platform string
        
    Returns:
        Dict: Complete platform information, or None if not found
    """
    moonbit_data = _load_moonbit_checksums_from_json(repository_ctx)
    
    versions = moonbit_data.get("versions", {})
    version_data = versions.get(version, {})
    platforms = version_data.get("platforms", {})
    
    return platforms.get(platform)

def get_latest_moonbit_version(repository_ctx):
    """Get latest available MoonBit version
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        String: Latest version, or None if not found
    """
    moonbit_data = _load_moonbit_checksums_from_json(repository_ctx)
    versions = moonbit_data.get("versions", {})
    
    # Simple approach: return the highest version number
    if not versions:
        return None
    
    return max(versions.keys())

def get_github_repo():
    """Get MoonBit GitHub repository

    Returns:
        String: GitHub repository path
    """
    return "moonbitlang/moon"

def get_moonbit_core_info(repository_ctx, version):
    """Get MoonBit core library information from centralized registry

    Args:
        repository_ctx: Repository context for file operations
        version: MoonBit version string (e.g., 'latest')

    Returns:
        Dict: Core library information with sha256 and url_suffix, or None if not found
    """
    moonbit_data = _load_moonbit_checksums_from_json(repository_ctx)

    cores = moonbit_data.get("cores", {})
    return cores.get(version)
