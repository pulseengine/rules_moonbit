"""Enhanced MoonBit checksum registry API with backward compatibility

This module provides a unified API for accessing MoonBit tool checksums
with support for both legacy and new JSON formats.
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

# Load legacy registry for backward compatibility
load(":registry.bzl", "get_moonbit_checksum", "get_moonbit_info", "get_latest_moonbit_version", "get_github_repo")

# For now, we use the legacy format exclusively
USE_NEW_CHECKSUM_UPDATER = False

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
    # Use legacy method
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
    # Use legacy method
    return get_moonbit_info(repository_ctx, version, platform)

def get_latest_moonbit_version_v2(repository_ctx):
    """Get latest available MoonBit version from enhanced registry
    
    Args:
        repository_ctx: Repository context for file operations
        
    Returns:
        String: Latest version, or None if not found
    """
    # Use legacy method
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

# Note: Backward compatibility is handled by the legacy registry.bzl file