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

"""Enhanced MoonBit checksum registry API with backward compatibility

This module provides a unified API for accessing MoonBit tool checksums
with support for both legacy and new JSON formats.
"""

# Load legacy registry for backward compatibility
load(":registry.bzl", "get_moonbit_checksum", "get_moonbit_info", "get_latest_moonbit_version", "get_github_repo")

# Check if we should use the new MoonBit checksum updater
USE_NEW_CHECKSUM_UPDATER = False

# Try to detect if new checksum updater is available
try:
    # This will be set to True when the MoonBit checksum updater is integrated
    USE_NEW_CHECKSUM_UPDATER = False
    # In future, this will be: native.exists("@moonbit_checksum_updater//:checksum_updater")
except:
    pass

def _load_moonbit_checksums_v2(repository_ctx):
    """Load checksums using new MoonBit checksum updater format
    
    This function attempts to load checksums using the new comprehensive format.
    If the new format is not available, it falls back to the legacy format.
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        Dict: MoonBit tool data from JSON file
    """
    # First try the new format
    if USE_NEW_CHECKSUM_UPDATER:
        try:
            json_file = repository_ctx.path(Label("@rules_moonbit//moonbit/checksums:moonbit_v2.json"))
            if json_file.exists:
                content = repository_ctx.read(json_file)
                return json.decode(content)
        except:
            pass
    
    # Fall back to legacy format
    return {
        "tool_name": "moonbit",
        "github_repo": get_github_repo(),
        "latest_version": get_latest_moonbit_version(repository_ctx),
        "last_checked": "2026-01-01T00:00:00Z",
        "build_type": "binary",
        "versions": _convert_legacy_to_new_format(repository_ctx),
        "supported_platforms": [
            "darwin_amd64", "darwin_arm64",
            "linux_amd64", "linux_arm64",
            "windows_amd64"
        ]
    }

def _convert_legacy_to_new_format(repository_ctx):
    """Convert legacy JSON format to new comprehensive format
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        Dict: Versions in new format
    """
    versions = {}
    
    # Load legacy data
    legacy_data = {
        "versions": {
            "latest": {"platforms": {}},
            "0.6.33": {"platforms": {}}
        }
    }
    
    try:
        json_file = repository_ctx.path(Label("@rules_moonbit//moonbit/checksums:moonbit.json"))
        if json_file.exists:
            content = repository_ctx.read(json_file)
            legacy_data = json.decode(content)
    except:
        pass
    
    # Convert each version
    for version_name, version_data in legacy_data.get("versions", {}).items():
        if version_name == "latest":
            # Skip "latest" as it's not a real version
            continue
            
        new_version_data = {
            "release_date": "2026-01-01",  # Default date
            "platforms": {}
        }
        
        # Convert platforms
        for platform_name, platform_data in version_data.get("platforms", {}).items():
            # Map legacy platform names to new format
            new_platform_name = _map_legacy_platform(platform_name)
            
            new_version_data["platforms"][new_platform_name] = {
                "sha256": platform_data.get("sha256", ""),
                "url_suffix": platform_data.get("url_suffix", ""),
                "binaries": platform_data.get("binaries", []),
                "archive_type": "tar.gz" if platform_data.get("url_suffix", "").endswith(".tar.gz") else "zip"
            }
        
        versions[version_name] = new_version_data
    
    return versions

def _map_legacy_platform(legacy_name):
    """Map legacy platform names to new standard format
    
    Args:
        legacy_name: Legacy platform name
        
    Returns:
        String: New platform name
    """
    mappings = {
        "darwin_aarch64": "darwin_arm64",
        "linux_x86_64": "linux_amd64",
        "windows_x86_64": "windows_amd64",
        "darwin_x86_64": "darwin_amd64",
        "linux_arm64": "linux_arm64"
    }
    
    return mappings.get(legacy_name, legacy_name)

def get_moonbit_checksum_v2(repository_ctx, version, platform):
    """Get verified checksum from enhanced registry
    
    This function supports both legacy and new JSON formats.
    
    Args:
        repository_ctx: Repository context for file operations
        version: MoonBit version string (e.g., '0.6.33')
        platform: Platform string (e.g., 'darwin_arm64', 'linux_amd64')
        
    Returns:
        String: SHA256 checksum, or None if not found
    """
    # Try new format first
    if USE_NEW_CHECKSUM_UPDATER:
        try:
            tool_data = _load_moonbit_checksums_v2(repository_ctx)
            versions = tool_data.get("versions", {})
            version_data = versions.get(version, {})
            platforms = version_data.get("platforms", {})
            platform_data = platforms.get(platform, {})
            return platform_data.get("sha256")
        except:
            pass
    
    # Fall back to legacy method
    return get_moonbit_checksum(repository_ctx, version, platform)

def get_moonbit_info_v2(repository_ctx, version, platform):
    """Get complete MoonBit information from enhanced registry
    
    Args:
        repository_ctx: Repository context for file operations
        version: MoonBit version string
        platform: Platform string
        
    Returns:
        Dict: Complete platform information, or None if not found
    """
    # Try new format first
    if USE_NEW_CHECKSUM_UPDATER:
        try:
            tool_data = _load_moonbit_checksums_v2(repository_ctx)
            versions = tool_data.get("versions", {})
            version_data = versions.get(version, {})
            platforms = version_data.get("platforms", {})
            return platforms.get(platform)
        except:
            pass
    
    # Fall back to legacy method
    return get_moonbit_info(repository_ctx, version, platform)

def get_latest_moonbit_version_v2(repository_ctx):
    """Get latest available MoonBit version from enhanced registry
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        String: Latest version, or None if not found
    """
    # Try new format first
    if USE_NEW_CHECKSUM_UPDATER:
        try:
            tool_data = _load_moonbit_checksums_v2(repository_ctx)
            return tool_data.get("latest_version")
        except:
            pass
    
    # Fall back to legacy method
    return get_latest_moonbit_version(repository_ctx)

def get_github_repo_v2():
    """Get MoonBit GitHub repository
    
    Returns:
        String: GitHub repository in 'owner/repo' format
    """
    return "moonbitlang/moonbit"

def get_tool_metadata(repository_ctx):
    """Get comprehensive tool metadata
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        Dict: Tool metadata including github_repo, latest_version, etc.
    """
    return {
        "tool_name": "moonbit",
        "github_repo": get_github_repo_v2(),
        "latest_version": get_latest_moonbit_version_v2(repository_ctx),
        "build_type": "binary",
        "supported_platforms": [
            "darwin_amd64", "darwin_arm64",
            "linux_amd64", "linux_arm64",
            "windows_amd64"
        ]
    }

def list_supported_platforms(repository_ctx):
    """List all supported platforms for MoonBit
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        List: List of supported platform strings
    """
    metadata = get_tool_metadata(repository_ctx)
    return metadata.get("supported_platforms", [])

def validate_tool_exists(repository_ctx, version, platform):
    """Validate that a tool version and platform combination exists
    
    Args:
        repository_ctx: Repository context for file operations
        version: MoonBit version string
        platform: Platform string
        
    Returns:
        Bool: True if the combination exists and has a checksum
    """
    checksum = get_moonbit_checksum_v2(repository_ctx, version, platform)
    return checksum != None and len(checksum) == 64  # Valid SHA256 length

# Backward compatibility aliases
get_moonbit_checksum = get_moonbit_checksum_v2
get_moonbit_info = get_moonbit_info_v2  
get_latest_moonbit_version = get_latest_moonbit_version_v2
get_github_repo = get_github_repo_v2