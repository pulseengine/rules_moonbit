# MoonBit Platform Support Status

This document tracks the current status of MoonBit platform support in rules_moonbit.

## 📋 Platform Support Matrix

| Platform | Status | Checksum | URL Suffix | Binaries | Notes |
|----------|--------|----------|------------|----------|-------|
| `darwin_arm64` | ✅ Verified | `89d87662194a4a2d7cc345b1fecf8bbe42e0a00ee7e68c8f2e407f3f3da4b51f` | `moonbit-darwin-aarch64.tar.gz` | `moon` | macOS Apple Silicon |
| `darwin_amd64` | ❌ Needed | `TODO` | `moonbit-darwin-x86_64.tar.gz` | `moon` | macOS Intel |
| `linux_amd64` | ✅ Verified | `401d0c5408819a0ed6197d2db54c10e17fe16c6e5654df1bf8b2de71a9bbc1e5` | `moonbit-linux-x86_64.tar.gz` | `moon` | Linux x86_64 |
| `linux_arm64` | ❌ Needed | `TODO` | `moonbit-linux-arm64.tar.gz` | `moon` | Linux ARM64 |
| `windows_amd64` | ❌ Needed | `TODO` | `moonbit-windows-x86_64.zip` | `moon.exe` | Windows x86_64 |

## 🎯 Status Legend

- **✅ Verified**: Checksum verified and working
- **❌ Needed**: Checksum needed (TODO)
- **🟡 Experimental**: Experimental support
- **❓ Unknown**: Status unknown

## 🔧 How to Add Missing Checksums

### 1. Obtain the Platform Binary

Download the official MoonBit binary for the target platform.

### 2. Compute the Checksum

```bash
# For macOS/Linux
shasum -a 256 moonbit-*.tar.gz

# For Windows
sha256sum moonbit-*.zip
```

### 3. Update the Checksum Registry

Edit `moonbit.json` and update the platform information:

```json
{
  "sha256": "computed_checksum_here",
  "status": "verified"
}
```

### 4. Test the Platform

Build the examples to ensure the platform works:

```bash
bazel build //examples/simple:simple_lib
```

## 📈 Platform Priority

### High Priority (Core Platforms)
1. **windows_amd64** - Windows support is important for many users
2. **darwin_amd64** - macOS Intel is still widely used

### Medium Priority (Emerging Platforms)
3. **linux_arm64** - ARM64 Linux is growing in popularity

### Low Priority (Specialized Platforms)
4. **linux_riscv64** - RISC-V support (future)
5. **windows_arm64** - Windows ARM64 (future)

## 🎯 Platform Detection

The hermetic toolchain automatically detects platforms using this mapping:

| Bazel Platform | MoonBit Platform | Notes |
|----------------|------------------|-------|
| `@platforms//os:darwin` + `arm64` | `darwin_arm64` | macOS Apple Silicon |
| `@platforms//os:darwin` + `x86_64` | `darwin_amd64` | macOS Intel |
| `@platforms//os:linux` + `x86_64` | `linux_amd64` | Linux x86_64 |
| `@platforms//os:linux` + `arm64` | `linux_arm64` | Linux ARM64 |
| `@platforms//os:windows` + `x86_64` | `windows_amd64` | Windows x86_64 |

## 🔒 Checksum Verification

All downloads are verified using SHA256 checksums to ensure:
- **Integrity**: Files are not corrupted during download
- **Authenticity**: Files come from official MoonBit sources
- **Reproducibility**: Same checksums produce same build results

## 🛠️ Tools Available

### `tools/get_windows_checksum.sh`

Script to obtain Windows checksum:

```bash
./tools/get_windows_checksum.sh
```

### Manual Verification

For other platforms, use the appropriate checksum tool:

```bash
# macOS/Linux
shasum -a 256 moonbit-*.tar.gz

# Windows (PowerShell)
Get-FileHash -Algorithm SHA256 moonbit-*.zip
```

## 📚 Related Documentation

- [Hermetic Toolchain Setup](../HERMETIC_TOOLCHAIN.md)
- [Checksum Registry API](registry.bzl)
- [Adding New Platforms](../tools/README.md)

## 🎉 Contributing

To help improve platform support:

1. **Test existing platforms**: Verify checksums on your platform
2. **Add missing checksums**: Contribute checksums for unsupported platforms
3. **Report issues**: Let us know about platform-specific problems
4. **Suggest platforms**: Request support for additional platforms

All contributions are welcome! Please submit pull requests with:
- Updated checksums
- Platform-specific fixes
- Improved documentation

## 📋 Changelog

### Current Status (2024)
- ✅ macOS Apple Silicon support
- ✅ Linux x86_64 support
- ❌ Windows x86_64 (checksum needed)
- ❌ macOS Intel (checksum needed)
- ❌ Linux ARM64 (checksum needed)

### Future Plans
- Add Windows support when checksum available
- Add macOS Intel support
- Add Linux ARM64 support
- Explore RISC-V and other architectures

## 🔗 Official Resources

- [MoonBit Language](https://www.moonbitlang.com)
- [MoonBit Documentation](https://www.moonbitlang.com/docs)
- [MoonBit GitHub](https://github.com/moonbitlang/moonbit)
- [MoonBit CLI](https://cli.moonbitlang.com)

The platform support will continue to expand as MoonBit adds official support for more platforms!