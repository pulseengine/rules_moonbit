"""MoonBit checksum updater tool"""

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

load("@bazel_skylib//lib:http.bzl", "http_archive", "http_file")
load("@bazel_skylib//lib:json.bzl", "json")
load("//moonbit/checksums:registry.bzl", "get_github_repo")

def fetch_github_releases(repository_ctx, version = None):
    """Fetch MoonBit releases from GitHub API
    
    Args:
        repository_ctx: Repository context
        version: Specific version to fetch (None for all)
        
    Returns:
        List of release information
    """
    github_repo = get_github_repo()
    
    # Use GitHub API to fetch releases
    # Note: In a real implementation, this would use proper HTTP requests
    # For now, we'll simulate the response
    
    # Simulated response for demonstration
    releases = [
        {
            "tag_name": "v0.6.33",
            "assets": [
                {
                    "name": "moonbit-0.6.33-darwin-arm64.tar.gz",
                    "browser_download_url": "https://github.com/moonbitlang/moonbit/releases/download/v0.6.33/moonbit-0.6.33-darwin-arm64.tar.gz"
                },
                {
                    "name": "moonbit-0.6.33-darwin-amd64.tar.gz",
                    "browser_download_url": "https://github.com/moonbitlang/moonbit/releases/download/v0.6.33/moonbit-0.6.33-darwin-amd64.tar.gz"
                },
                {
                    "name": "moonbit-0.6.33-linux-amd64.tar.gz",
                    "browser_download_url": "https://github.com/moonbitlang/moonbit/releases/download/v0.6.33/moonbit-0.6.33-linux-amd64.tar.gz"
                },
                {
                    "name": "moonbit-0.6.33-linux-arm64.tar.gz",
                    "browser_download_url": "https://github.com/moonbitlang/moonbit/releases/download/v0.6.33/moonbit-0.6.33-linux-arm64.tar.gz"
                }
            ]
        }
    ]
    
    if version:
        releases = [r for r in releases if r["tag_name"] == "v" + version]
    
    return releases

def calculate_checksum(repository_ctx, url):
    """Calculate SHA256 checksum for a download
    
    Args:
        repository_ctx: Repository context
        url: URL to download
        
    Returns:
        SHA256 checksum
    """
    # In a real implementation, this would:
    # 1. Download the file
    # 2. Calculate SHA256 checksum
    # 3. Return the checksum
    
    # For now, return a placeholder
    return "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"

def update_checksum_registry(repository_ctx, version = None):
    """Update checksum registry with new MoonBit releases
    
    Args:
        repository_ctx: Repository context
        version: Specific version to update (None for all)
        
    Returns:
        Updated checksum data
    """
    # Fetch releases from GitHub
    releases = fetch_github_releases(repository_ctx, version)
    
    # Build checksum data structure
    checksum_data = {"versions": {}}
    
    for release in releases:
        version_name = release["tag_name"][1:]  # Remove 'v' prefix
        platforms = {}
        
        for asset in release["assets"]:
            # Extract platform from filename
            filename = asset["name"]
            if filename.startswith("moonbit-") and filename.endswith(".tar.gz"):
                # Extract version and platform from filename
                parts = filename[len("moonbit-"):-len(".tar.gz")].split("-")
                if len(parts) == 2:
                    file_version, platform = parts
                    
                    # Calculate checksum (simulated)
                    checksum = calculate_checksum(repository_ctx, asset["browser_download_url"])
                    
                    platforms[platform] = {
                        "sha256": checksum,
                        "url_suffix": filename,
                        "binaries": ["moon"]
                    }
        
        if platforms:
            checksum_data["versions"][version_name] = {"platforms": platforms}
    
    return checksum_data

def generate_checksum_json(repository_ctx, output_file, version = None):
    """Generate checksum JSON file
    
    Args:
        repository_ctx: Repository context
        output_file: Output file path
        version: Specific version to include (None for all)
    """
    checksum_data = update_checksum_registry(repository_ctx, version)
    
    # Write JSON file
    content = json.encode(checksum_data, indent = 2)
    repository_ctx.write(output_file, content)
    
    return output_file

# Checksum updater rule for use in BUILD files
def moonbit_checksum_updater(
    name,
    version = None,
    output = "moonbit.json",
):
    """MoonBit checksum updater rule
    
    Args:
        name: Rule name
        version: Specific version to update
        output: Output JSON file
    """
    native.repository_rule(
        name = name,
        implementation = lambda ctx: generate_checksum_json(ctx, ctx.attr.output, version),
        attrs = {
            "version": attr.string(default = None),
            "output": attr.label(default = Label("moonbit.json")),
        },
        local = True,
    )
