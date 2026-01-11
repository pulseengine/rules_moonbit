"""Test hermetic toolchain functionality"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest")
load("//moonbit/checksums:registry.bzl", 
     "get_moonbit_checksum", 
     "get_moonbit_info", 
     "get_latest_moonbit_version")

def test_checksum_registry_impl(ctx):
    """Test checksum registry functionality"""
    env = analysistest.begin(ctx)
    
    # Test latest version retrieval
    latest_version = get_latest_moonbit_version(env)
    analysistest.assert_equals(env, latest_version, "0.6.33")
    
    # Test checksum retrieval
    checksum = get_moonbit_checksum(env, "0.6.33", "darwin_arm64")
    analysistest.assert_not_equals(env, checksum, None)
    analysistest.assert_equals(env, 
        len(checksum), 64,  # SHA256 checksum length
        msg="Checksum should be 64 characters")
    
    # Test tool info retrieval
    tool_info = get_moonbit_info(env, "0.6.33", "darwin_arm64")
    analysistest.assert_not_equals(env, tool_info, None)
    analysistest.assert_equals(env, tool_info.get("url_suffix"), "moonbit-0.6.33-darwin-arm64.tar.gz")
    
    return analysistest.end(env)

def test_vendor_toolchain_impl(ctx):
    """Test vendor toolchain functionality"""
    env = analysistest.begin(ctx)
    
    # Test that vendor system can be loaded
    load("//moonbit/tools:vendor_toolchains.bzl", "vendor_moonbit_toolchain")
    
    # Verify the function exists
    analysistest.assert_true(env, "vendor_moonbit_toolchain" in dir())
    
    return analysistest.end(env)

toolchain_checksum_test = analysistest.make(test_checksum_registry_impl)
toolchain_vendor_test = analysistest.make(test_vendor_toolchain_impl)
