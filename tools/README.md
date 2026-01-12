# MoonBit Tools

This directory contains utilities for managing MoonBit toolchains and checksums.

## 📋 Available Tools

### `get_windows_checksum.sh`

Script to obtain the Windows MoonBit checksum for the checksum registry.

**Usage:**
```bash
./get_windows_checksum.sh
```

**What it does:**
1. Attempts to download the Windows version of MoonBit
2. Computes the SHA256 checksum
3. Shows how to update the checksum registry
4. Cleans up temporary files

**Note:** The Windows download may timeout or fail if the Windows version is not yet available from the MoonBit CLI.

## 🔧 Adding New Platforms

To add support for additional platforms:

### 1. Obtain the Platform Binary

Download the MoonBit binary for your platform from the official source.

### 2. Compute the Checksum

```bash
# For macOS/Linux
shasum -a 256 moonbit-*.tar.gz

# For Windows
sha256sum moonbit-*.zip
```

### 3. Update the Checksum Registry

Edit `moonbit/checksums/moonbit.json` and add the platform information:

```json
{
  "versions": {
    "0.6.33": {
      "platforms": {
        "your_platform": {
          "sha256": "computed_checksum_here",
          "url_suffix": "moonbit-your_platform.tar.gz",
          "binaries": ["moon"]
        }
      }
    }
  }
}
```

### 4. Test the New Platform

Build the examples to ensure the new platform works:

```bash
bazel build //examples/simple:simple_lib
```

## 📁 Checksum Registry Structure

The checksum registry (`moonbit/checksums/moonbit.json`) contains:

- **versions**: MoonBit versions with their platform-specific information
- **platforms**: Platform-specific download and checksum information
- **sha256**: SHA256 checksum for verification
- **url_suffix**: Filename for the download
- **binaries**: Executable names in the archive

## 🎯 Platform Naming Convention

Platform names follow this convention:

- **macOS Apple Silicon**: `darwin_arm64` or `darwin_aarch64`
- **macOS Intel**: `darwin_amd64` or `darwin_x86_64`
- **Linux x86_64**: `linux_amd64`
- **Linux ARM64**: `linux_arm64`
- **Windows x86_64**: `windows_amd64`

## 🔒 Checksum Verification

All downloads are verified using SHA256 checksums. This ensures:

- **Integrity**: Files are not corrupted
- **Authenticity**: Files come from official sources
- **Reproducibility**: Same checksums produce same results

## 🛠️ Troubleshooting

### Download Failures

If downloads fail:
1. Check your internet connection
2. Verify the URL is correct
3. Check if the platform/version is available
4. Try again later (may be temporary issue)

### Checksum Mismatches

If checksums don't match:
1. Verify you downloaded the correct file
2. Recompute the checksum
3. Check for file corruption
4. Update the registry if needed

## 📚 Related Documentation

- [Hermetic Toolchain Setup](../HERMETIC_TOOLCHAIN.md)
- [Checksum Registry API](../moonbit/checksums/registry.bzl)
- [MoonBit Official Documentation](https://www.moonbitlang.com/docs)

## 🎉 Contributing

To add new tools or improve existing ones:

1. Create a new script in this directory
2. Add documentation to this README
3. Test thoroughly
4. Submit a pull request

All tools should follow the existing patterns and include proper error handling.