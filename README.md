# Rules_Moonbit

Bazel rules for building MoonBit projects.

## Status

This project is in the early development phase. The goal is to create Bazel rules that integrate with MoonBit's build system while maintaining Bazel's core principles.

## Getting Started

### Prerequisites

- Bazel 8.5+ (required for modern toolchain support)
- Basic understanding of Bazel

### Quick Start (Development Setup)

Since the MoonBit compiler is not yet publicly available for hermetic download, here's how to set up for development:

#### Option 1: Using Test Toolchain (Recommended)

```python
# In your WORKSPACE file:

# First, get rules_moonbit (local development)
local_repository(
    name = "rules_moonbit",
    path = "/path/to/rules_moonbit",
)

# Use the test toolchain
local_repository(
    name = "moonbit_toolchain",
    path = "moonbit_toolchain",
)

# Register the toolchain
register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
```

#### Option 2: Using Bzlmod (Modern Bazel)

```python
# In your MODULE.bazel file:

bazel_dep(name = "rules_moonbit", version = "0.1.0")

# For now, use local toolchain until hermetic downloads work
local_repository(
    name = "moonbit_toolchain",
    path = "moonbit_toolchain",
)

register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
```

#### Option 3: When Hermetic Downloads Become Available

```python
# In your WORKSPACE file:

load("@rules_moonbit//moonbit/tools:hermetic_toolchain.bzl", "moonbit_toolchain_repository")

moonbit_toolchain_repository(
    name = "moonbit_toolchain",
    version = "0.6.33",  # or latest version
)

register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
```

2. Create a BUILD file:

```python
load("@rules_moonbit//moonbit:defs.bzl", "moonbit_library", "moonbit_binary")

moonbit_library(
    name = "mylib",
    srcs = ["mylib.mbt"],
    deps = ["//:otherlib"],
)

moonbit_binary(
    name = "myapp",
    srcs = ["main.mbt"],
    deps = [":mylib"],
)
```

### Advanced Usage

#### Cross-Compilation

```python
moonbit_binary(
    name = "linux_app",
    srcs = ["main.mbt"],
    target_platform = "linux_x86_64",
    optimization = "aggressive",
    caching = True,
)
```

#### WebAssembly Component Model

```python
moonbit_component(
    name = "math_component",
    srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
    target_platform = "wasm",
)
```

#### Package Management

```python
moonbit_package(
    name = "dependencies",
    packages = [
        "@moonbit_registry//:math",
        "@moonbit_registry//:collections",
    ],
    features = ["serde", "async"],
)
```

## Features

### Core Features

- **MoonBit Compilation**: Full support for MoonBit language compilation
- **Multi-Target Support**: Compile to WASM, JavaScript, C, and native targets
- **Cross-Compilation**: Build for different platforms (Linux, Windows, macOS)
- **WebAssembly Component Model**: Create WASM components with WIT interface support
- **Package Management**: Dependency management with MoonBit registry integration
- **Hermetic Toolchain**: Automatic MoonBit toolchain download and management
- **Incremental Compilation**: Faster rebuilds with incremental compilation
- **Performance Optimization**: Multiple optimization levels and caching strategies

### Advanced Features

- **Toolchain Discovery**: Automatic detection of MoonBit installations
- **Platform Detection**: Intelligent platform detection for cross-compilation
- **Caching Strategies**: Content-addressable caching for build acceleration
- **Optimization Levels**: Debug, release, and aggressive optimization modes
- **Component Model Integration**: Seamless integration with rules_wasm_component
- **Package Resolution**: Cargo-like dependency resolution algorithm
- **Checksum Verification**: Hermetic builds with checksum validation
- **Metadata Generation**: Comprehensive build metadata and reporting

## MoonBit Checksum Updater

The MoonBit Checksum Updater provides comprehensive checksum management for the MoonBit ecosystem:

### Features

- **GitHub API Integration**: Automatically fetch latest releases from GitHub
- **SHA256 Computation**: Native MoonBit crypto with multiple fallback strategies
- **Async/Await Support**: Parallel processing for multiple tools
- **Comprehensive Error Handling**: Rich error taxonomy with retry logic
- **Validation System**: Strict modes and auto-fix capabilities

### Installation

The checksum updater is integrated into rules_moonbit and provides:

1. **Enhanced Checksum Registry**: `moonbit/checksums/registry_v2.bzl`
2. **Comprehensive JSON Format**: `moonbit/checksums/moonbit_v2.json`
3. **Backward Compatibility**: Full support for legacy format

### Usage

```bash
# Update all tools
bazel run @moonbit_checksum_updater//:checksum_updater -- update --all

# Update specific tools with async processing
bazel run @moonbit_checksum_updater//:checksum_updater -- update --tools wasm-tools,wit-bindgen --async

# Validate checksums with strict mode
bazel run @moonbit_checksum_updater//:checksum_updater -- validate --all --strict --verify-download

# Check for common issues
bazel run @moonbit_checksum_updater//:checksum_updater -- check --tool wasm-tools
```

### Supported Tools

- **MoonBit Tools**: moonbit compiler
- **WebAssembly Tools**: wasm-tools, wit-bindgen, wasmtime, wasi-sdk
- **Other Tools**: tinygo, nodejs, jco, etc.

### Platform Support

- `darwin_amd64` (macOS Intel)
- `darwin_arm64` (macOS Apple Silicon)
- `linux_amd64` (Linux x86_64)
- `linux_arm64` (Linux ARM64)
- `windows_amd64` (Windows x86_64)

## Development

### Repository Structure

```
moonbit/
├── defs.bzl                # Public API
├── private/                # Internal implementation
│   ├── moon.bzl            # Core rules
│   ├── toolchain.bzl       # Toolchain implementation
│   ├── package_utils.bzl   # Package management
│   ├── compilation.bzl     # Compilation logic
│   ├── optimization_utils.bzl # Optimization features
│   └── platforms.bzl       # Platform definitions
├── providers.bzl           # MoonBit providers
├── examples/              # Usage examples
│   ├── simple/            # Basic examples
│   ├── component_integration/ # WASM Component Model
│   ├── package_registry/   # Package management
│   └── cross_compilation/  # Cross-compilation examples
├── checksums/             # Toolchain checksums
│   ├── registry.bzl       # Legacy registry (backward compatibility)
│   ├── registry_v2.bzl     # Enhanced registry with new features
│   ├── moonbit.json       # Legacy checksum format
│   └── moonbit_v2.json     # New comprehensive checksum format
└── tools/                 # Toolchain utilities
    └── vendor_toolchains.bzl # Enhanced vendor system
```

### Building

```bash
bazel build //...
bazel test //...
```

### Testing

Run the test suite:

```bash
bazel test //test/...
```

## Contributing

See CONTRIBUTING.md for contribution guidelines.

## License

Apache License 2.0
