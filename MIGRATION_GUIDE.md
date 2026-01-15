# MoonBit Checksum Updater Migration Guide

This guide provides step-by-step instructions for migrating from the legacy checksum system to the enhanced MoonBit Checksum Updater.

## 🎯 Overview

The MoonBit Checksum Updater introduces:
- **Enhanced JSON format** with comprehensive metadata
- **GitHub API integration** for automatic updates
- **Async/await support** for parallel processing
- **Comprehensive error handling** with retry logic
- **Validation system** with auto-fix capabilities

## 🚀 Migration Path

### Phase 1: Preparation (No Breaking Changes)

1. **Copy Enhanced Files**
   ```bash
   # Copy the enhanced registry
   cp registry_v2.bzl /path/to/rules_moonbit/moonbit/checksums/registry_v2.bzl
   
   # Copy the migrated JSON
   cp moonbit_v2.json /path/to/rules_moonbit/moonbit/checksums/moonbit_v2.json
   ```

2. **Update BUILD.bazel**
   ```bazel
   # In moonbit/checksums/BUILD.bazel
   exports_files([
       "moonbit.json",      # Legacy format (backward compatibility)
       "moonbit_v2.json",   # New comprehensive format
   ])
   
   exports_files([
       "registry.bzl",      # Legacy registry
       "registry_v2.bzl",   # Enhanced registry with new features
   ])
   ```

3. **Update vendor_toolchains.bzl**
   ```bazel
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
       
       USE_NEW_CHECKSUM_UPDATER = True
   except:
       # Fall back to legacy registry
       load("//moonbit/checksums:registry.bzl", 
            "get_moonbit_checksum", 
            "get_moonbit_info", 
            "get_github_repo",
            "get_latest_moonbit_version")
       
       USE_NEW_CHECKSUM_UPDATER = False
   ```

### Phase 2: Testing

1. **Verify Backward Compatibility**
   ```bash
   # Test that existing builds still work
   bazel build //...
   bazel test //...
   ```

2. **Test New Features**
   ```bash
   # Test the enhanced registry
   bazel build //moonbit/checksums:checksum_integration_test
   ```

3. **Run Integration Tests**
   ```bash
   # Run the integration test suite
   bazel test //moonbit/checksums:checksum_integration_test
   ```

### Phase 3: Gradual Adoption

1. **Enable New Features**
   ```bazel
   # In vendor_toolchains.bzl
   USE_NEW_CHECKSUM_UPDATER = True  # Enable enhanced features
   ```

2. **Update Checksums**
   ```bash
   # Use the checksum updater to fetch latest releases
   checksum_updater update --all
   ```

3. **Validate Checksums**
   ```bash
   # Validate all checksums
   checksum_updater validate --all --strict --verify-download
   ```

## 📋 Detailed Migration Steps

### Step 1: File Preparation

**Files to Copy:**
- `registry_v2.bzl` → Enhanced registry with new features
- `moonbit_v2.json` → New comprehensive checksum format

**Files to Update:**
- `BUILD.bazel` → Export both legacy and new files
- `vendor_toolchains.bzl` → Use enhanced registry with fallback

### Step 2: JSON Format Migration

**Legacy Format:**
```json
{
  "versions": {
    "0.6.33": {
      "platforms": {
        "darwin_arm64": {
          "sha256": "a1b2c3...",
          "url_suffix": "moonbit-0.6.33-darwin-arm64.tar.gz"
        }
      }
    }
  }
}
```

**New Format:**
```json
{
  "tool_name": "moonbit",
  "github_repo": "moonbitlang/moonbit",
  "latest_version": "0.6.33",
  "last_checked": "2026-01-01T00:00:00Z",
  "build_type": "binary",
  "versions": {
    "0.6.33": {
      "release_date": "2026-01-01",
      "platforms": {
        "darwin_arm64": {
          "sha256": "89d87662194a4a2d7cc345b1fecf8bbe42e0a00ee7e68c8f2e407f3f3da4b51f",
          "url_suffix": "moonbit-darwin-aarch64.tar.gz",
          "binaries": ["moon"],
          "archive_type": "tar.gz"
        }
      }
    }
  },
  "supported_platforms": [
    "darwin_amd64", "darwin_arm64",
    "linux_amd64", "linux_arm64",
    "windows_amd64"
  ]
}
```

### Step 3: Registry Integration

**Updated Import Statement:**
```bazel
# Before (legacy)
load("//moonbit/checksums:registry.bzl", 
     "get_moonbit_checksum", "get_moonbit_info")

# After (enhanced with fallback)
try:
    load("//moonbit/checksums:registry_v2.bzl", 
         "get_moonbit_checksum_v2", "get_moonbit_info_v2")
    get_moonbit_checksum = get_moonbit_checksum_v2
    get_moonbit_info = get_moonbit_info_v2
except:
    load("//moonbit/checksums:registry.bzl", 
         "get_moonbit_checksum", "get_moonbit_info")
```

### Step 4: Configuration

**Configuration Options:**
```bazel
# Enable new checksum updater features
USE_NEW_CHECKSUM_UPDATER = True

# Enable strict validation mode
STRICT_VALIDATION = False

# Enable checksum verification by download
VERIFY_BY_DOWNLOAD = False
```

## 🔧 Troubleshooting

### Common Issues

**Issue: "File not found" errors**
- **Solution**: Verify that both `moonbit.json` and `moonbit_v2.json` exist in the checksums directory

**Issue: Checksum validation failures**
- **Solution**: Run `checksum_updater validate --all --fix` to automatically fix checksum issues

**Issue: GitHub API rate limiting**
- **Solution**: Add a GitHub API token to the configuration or use exponential backoff

**Issue: Platform not supported**
- **Solution**: Update `supported_platforms` in the JSON file or add the missing platform

### Debugging

**Enable Debug Logging:**
```bash
checksum_updater update --all --verbose
```

**Test Specific Tools:**
```bash
checksum_updater update --tools wasm-tools --dry-run
```

**Validate Checksums:**
```bash
checksum_updater validate --tools wasm-tools --strict
```

## ✅ Verification Checklist

- [ ] Copied `registry_v2.bzl` to rules_moonbit
- [ ] Copied `moonbit_v2.json` to rules_moonbit
- [ ] Updated `BUILD.bazel` to export both files
- [ ] Updated `vendor_toolchains.bzl` with fallback logic
- [ ] Verified backward compatibility (legacy builds work)
- [ ] Tested new features (enhanced registry works)
- [ ] Ran integration tests (all tests pass)
- [ ] Updated documentation (README, HERMETIC_TOOLCHAIN.md, JSON_INTEGRATION.md)

## 🎉 Benefits of Migration

1. **Automatic Updates**: Fetch latest releases from GitHub automatically
2. **Comprehensive Validation**: Strict validation with auto-fix capabilities
3. **Parallel Processing**: Faster updates with async/await support
4. **Better Error Handling**: User-friendly error messages and retry logic
5. **Cross-Platform Support**: Enhanced platform detection and support
6. **Future-Proof**: Clear path for WebAssembly component integration

## 📚 Additional Resources

- **Documentation**: See `HERMETIC_TOOLCHAIN.md` for detailed usage
- **Examples**: Check `examples/json_integration/` for working examples
- **API Reference**: See `registry_v2.bzl` for complete API documentation
- **Troubleshooting**: See `TROUBLESHOOTING.md` for common issues and solutions

## 🔮 Future Enhancements

1. **WebAssembly Component**: Port to WASM preview2 for universal compatibility
2. **Enterprise Features**: Proxy support, caching, and monitoring
3. **CI/CD Integration**: GitHub Actions workflows for automated updates
4. **Web UI**: Browser-based checksum management interface

The migration is designed to be **non-breaking** and **gradual**, ensuring that existing users experience no disruption while new users can take advantage of the enhanced checksum management system.