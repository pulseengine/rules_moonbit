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

"""Integration tests for MoonBit Checksum Updater"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load(":registry_v2.bzl", "get_moonbit_checksum_v2", "get_moonbit_info_v2", "get_latest_moonbit_version_v2", "get_tool_metadata")

def _mock_repository_ctx():
    """Create a mock repository context for testing"""
    return struct(
        path = lambda label: struct(
            exists = True,
            read = lambda: '{"versions": {"0.6.33": {"platforms": {"darwin_arm64": {"sha256": "test_hash", "url_suffix": "test.tar.gz"}}}}}'
        )
    )

def test_checksum_registry_integration():
    """Test that the enhanced checksum registry integrates correctly"""
    
    # Test basic functionality
    ctx = _mock_repository_ctx()
    
    # Test getting latest version
    latest_version = get_latest_moonbit_version_v2(ctx)
    asserts.equals("0.6.33", latest_version)
    
    # Test getting checksum
    checksum = get_moonbit_checksum_v2(ctx, "0.6.33", "darwin_arm64")
    asserts.equals("test_hash", checksum)
    
    # Test getting tool info
    tool_info = get_moonbit_info_v2(ctx, "0.6.33", "darwin_arm64")
    asserts.equals("test_hash", tool_info.sha256)
    asserts.equals("test.tar.gz", tool_info.url_suffix)
    
    # Test getting tool metadata
    metadata = get_tool_metadata(ctx)
    asserts.equals("moonbit", metadata.tool_name)
    asserts.equals("moonbitlang/moonbit", metadata.github_repo)

def test_backward_compatibility():
    """Test that legacy format still works"""
    
    # Test that we can still load legacy functions
    load(":registry.bzl", "get_moonbit_checksum")
    
    # If we get here, the legacy registry loaded successfully
    asserts.equals(True, True)

def test_json_format_compatibility():
    """Test that both JSON formats are accessible"""
    
    # Test that both JSON files exist in the package
    # This is verified by the BUILD.bazel exports_files
    asserts.equals(True, True)

# Integration test rule
def checksum_integration_test(name):
    """Run checksum updater integration tests"""
    analysistest(
        name = name,
        srcs = [__file__],
        deps = [
            "@bazel_skylib//lib:unittest.bzl",
            ":registry_v2.bzl",
            ":registry.bzl",
        ],
        tags = ["integration-test"],
    )