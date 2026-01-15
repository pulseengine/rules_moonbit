# Hermetic MoonBit Toolchain Setup

This guide explains how to set up and use the hermetic MoonBit toolchain with rules_moonbit.

## 🎯 Overview

The hermetic toolchain provides:
- **Reproducible builds** - Same inputs always produce same outputs
- **Checksum verification** - All downloads are verified with SHA256 checksums
- **No system dependencies** - MoonBit compiler is downloaded automatically
- **Cross-platform support** - Works on macOS, Linux, and Windows

## 🚀 Quick Start

### 1. Add the hermetic toolchain to your `MODULE.bazel`

```bazel
# MODULE.bazel
module(name = "your_project")

bazel_dep(name = "rules_moonbit", version = "0.1.0")

# Register hermetic MoonBit toolchain
moonbit_register_hermetic_toolchain(
    name = "moonbit_tools",
    version = "0.6.33",  # or "latest"
    platforms = ["darwin_arm64", "linux_amd64"],  # platforms you need
)
```

### 2. Use MoonBit rules in your `BUILD.bazel`

```bazel
# BUILD.bazel
load("@rules_moonbit//moonbit:defs.bzl", "moonbit_library", "moonbit_binary")

moonbit_library(
    name = "my_lib",
    srcs = ["lib.mbt"],
)

moonbit_binary(
    name = "my_app",
    srcs = ["main.mbt"],
    deps = [":my_lib"],
)
```

### 3. Build your project

```bash
bazel build //:my_app
```

The hermetic toolchain will be automatically downloaded and used!

## Architecture

```
┌───────────────────────────────────────────────────────┐
│                 rules_moonbit                          │
├───────────────────────────────────────────────────────┤
│                                                       │
│  ┌─────────────────┐    ┌─────────────────────────┐  │
│  │  Checksum       │    │  Toolchain Vendor      │  │
│  │  Registry       │    │  System               │  │
│  └─────────────────┘    └─────────────────────────┘  │
│          │                      │                   │
│          ▼                      ▼                   │
│  ┌─────────────────┐    ┌─────────────────────────┐  │
│  │  moonbit.json   │    │  vendor_moonbit_toolchain │
│  │  (verified      │    │  (Bazel repository rule)│  │
│  │   checksums)    │    └─────────────────────────┘  │
│  └─────────────────┘              │                   │
│                                  ▼                   │
│                           ┌─────────────────┐      │
│                           │  Hermetic       │      │
│                           │  Toolchain      │      │
│                           └─────────────────┘      │
│                                  │                   │
│                                  ▼                   │
│                           ┌─────────────────┐      │
│                           │  Bazel Toolchain│      │
│                           │  Registration   │      │
│                           └─────────────────┘      │
└───────────────────────────────────────────────────────┘
```

## Components

### 1. Checksum Registry (`moonbit/checksums/registry_v2.bzl`)

The enhanced checksum registry provides comprehensive checksum management:

- **Dual Format Support**: Both legacy (`moonbit.json`) and new comprehensive format (`moonbit_v2.json`)
- **Versioned**: Supports multiple MoonBit versions with release dates
- **Platform-aware**: Checksums for all platforms (darwin_arm64, darwin_amd64, linux_amd64, linux_arm64, windows_amd64)
- **Verified**: All downloads are checksum-verified
- **Metadata-rich**: Includes binaries, archive types, and comprehensive tool information

**New Comprehensive Format Example:**
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
        },
        "linux_amd64": {
          "sha256": "401d0c5408819a0ed6197d2db54c10e17fe16c6e5654df1bf8b2de71a9bbc1e5",
          "url_suffix": "moonbit-linux-x86_64.tar.gz",
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

**Backward Compatibility:**
- Legacy format (`moonbit.json`) still fully supported
- Automatic format detection and conversion
- Gradual migration path for existing users

### 2. MoonBit Checksum Updater (New!)

The MoonBit Checksum Updater provides automated checksum management:

- **GitHub API Integration**: Automatically fetch latest releases
- **SHA256 Computation**: Native MoonBit crypto with fallback strategies
- **Async/Await Support**: Parallel processing for multiple tools
- **Comprehensive Error Handling**: Rich error taxonomy with retry logic
- **Validation System**: Strict modes and auto-fix capabilities

**Usage:**
```bash
# Update all tools
checksum_updater update --all

# Update specific tools with async
checksum_updater update --tools wasm-tools,wit-bindgen --async

# Validate checksums with strict mode
checksum_updater validate --all --strict --verify-download
```

**Features:**
- ✅ Automatic release fetching from GitHub
- ✅ Platform pattern matching for asset detection
- ✅ Multi-strategy SHA256 computation (native, system tools, OpenSSL)
- ✅ Parallel tool updates with async/await
- ✅ Comprehensive validation with auto-fix
- ✅ User-friendly error messages and retry logic

### 2. Toolchain Vendor System (`moonbit/tools/vendor_toolchains.bzl`)

The vendor system handles hermetic toolchain downloads:

- **Bazel repository rules**: Uses Bazel's native download mechanism
- **GitHub releases**: Downloads from official MoonBit releases
- **Checksum verification**: Verifies all downloads
- **Platform detection**: Automatically detects and downloads correct platform

### 3. Toolchain Integration (`moonbit/private/toolchain.bzl`)

Integrates the hermetic toolchain with Bazel:

- **Toolchain provider**: Provides MoonBit toolchain information to rules
- **Registration**: Registers toolchain with Bazel's toolchain system
- **Fallback support**: Gracefully falls back to system installation if needed

## Usage

### Option 1: Hermetic Toolchain (Recommended)

```python
# In MODULE.bazel
module(name = "my_project", version = "1.0.0")

# Use rules_moonbit
bazel_dep(name = "rules_moonbit", version = "0.1.0")

# Set up hermetic MoonBit toolchain
moonbit_setup = use_extension("@rules_moonbit//moonbit:extensions.bzl", "moonbit_hermetic_toolchain_setup")
use_repo(moonbit_setup, "moonbit_toolchains")

# Register the toolchain
register_toolchains("@moonbit_toolchains//:all")
```

### Option 2: System Toolchain (Development)

```python
# In WORKSPACE (legacy mode)
load("@rules_moonbit//moonbit:defs.bzl", "moonbit_register_toolchains")

# Register system toolchain (uses 'moon' from PATH)
moonbit_register_toolchains(name = "moonbit_toolchains")
```

## Benefits

### 1. Reproducibility
- All developers use the exact same toolchain version
- No "works on my machine" issues
- CI/CD consistency

### 2. Security
- Checksum verification prevents tampering
- Official releases only
- No unaudited downloads

### 3. Convenience
- Automatic platform detection
- No manual installation required
- Version management through Bzlmod

### 4. Performance
- Bazel caching of downloads
- Incremental builds
- Parallel compilation

## Implementation Details

### Download Process

1. **Platform Detection**: Determine current platform (darwin_arm64, linux_amd64, etc.)
2. **Version Selection**: Get latest version from checksum registry
3. **URL Construction**: Build GitHub release URL
4. **Checksum Verification**: Download and verify against registry
5. **Toolchain Registration**: Register with Bazel's toolchain system

### Checksum Management

- **Centralized**: Single JSON file for all versions/platforms
- **Verified**: All checksums must be pre-populated
- **Update Process**: Use checksum updater tool to add new versions

### Platform Support

The system automatically supports:
- `darwin_arm64` (Apple Silicon Macs)
- `darwin_amd64` (Intel Macs)
- `linux_amd64` (Linux x86_64)
- `linux_arm64` (Linux ARM64)
- `windows_amd64` (Windows)

## Future Enhancements

### 1. Checksum Updater Tool
- Automatically fetch and verify new releases
- Update checksum registry
- Generate PRs for new versions

### 2. Version Pinning
- Support multiple MoonBit versions
- Version compatibility checking
- Migration tools

### 3. Advanced Caching
- Local caching of toolchains
- Team-wide cache sharing
- CI cache optimization

### 4. Cross-Compilation
- Multi-platform toolchain support
- Cross-compilation targets
- Platform-specific optimizations

## Comparison with Other Approaches

### rules_wasm_component Approach
- **Similarities**: Checksum registry, hermetic downloads, Bzlmod integration
- **Differences**: MoonBit has simpler toolchain (single binary vs multiple tools)

### rules_rust Approach
- **Similarities**: Toolchain registration, platform support
- **Differences**: MoonBit doesn't need complex stdlib management like Rust

### rules_go Approach
- **Similarities**: Single binary toolchain
- **Differences**: MoonBit has simpler compilation model than Go

## Conclusion

The hermetic toolchain approach provides a robust, secure, and convenient way to manage MoonBit toolchains in Bazel projects. It ensures reproducibility while maintaining flexibility for development environments.
