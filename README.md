<div align="center">

# rules_moonbit

<sup>Bazel rules for MoonBit projects</sup>

&nbsp;

![Bazel](https://img.shields.io/badge/Bazel-43A047?style=flat-square&logo=bazel&logoColor=white&labelColor=1a1b27)
![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square&labelColor=1a1b27)

</div>

&nbsp;

Bazel rules for building MoonBit projects with hermetic toolchain support, multi-target compilation, and WebAssembly Component Model integration.

> [!NOTE]
> Part of the PulseEngine toolchain. Provides build infrastructure for MoonBit-based components. See [moonbit_checksum_updater](https://github.com/pulseengine/moonbit_checksum_updater) for checksum management tooling.

## Status

Early development phase. The goal is to create Bazel rules that integrate with MoonBit's build system while maintaining Bazel's core principles.

## Getting Started

### Prerequisites

- Bazel 8.5+ (required for modern toolchain support)

### Quick Start

**Using Bzlmod (Modern Bazel):**

```python
# MODULE.bazel
bazel_dep(name = "rules_moonbit", version = "0.1.0")
```

**Using WORKSPACE:**

```python
local_repository(
    name = "rules_moonbit",
    path = "/path/to/rules_moonbit",
)

register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
```

**When Hermetic Downloads Become Available:**

```python
load("@rules_moonbit//moonbit/tools:hermetic_toolchain.bzl", "moonbit_toolchain_repository")

moonbit_toolchain_repository(
    name = "moonbit_toolchain",
    version = "0.6.33",
)

register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
```

### BUILD file

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

## Features

### Core
- MoonBit compilation with multi-target support (WASM, JavaScript, C, native)
- Cross-compilation for different platforms
- WebAssembly Component Model with WIT interface support
- Package management with MoonBit registry integration
- Hermetic toolchain with automatic download and management

### Advanced
- Incremental compilation for faster rebuilds
- Multiple optimization levels (debug, release, aggressive)
- Content-addressable caching for build acceleration
- Integration with rules_wasm_component
- Checksum verification for hermetic builds

## Advanced Usage

### Cross-Compilation

```python
moonbit_binary(
    name = "linux_app",
    srcs = ["main.mbt"],
    target_platform = "linux_x86_64",
    optimization = "aggressive",
)
```

### WebAssembly Component Model

```python
moonbit_component(
    name = "math_component",
    srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
    target_platform = "wasm",
)
```

## Development

```bash
bazel build //...     # Build
bazel test //...      # Test
bazel test //test/... # Run test suite
```

## Contributing

See CONTRIBUTING.md for contribution guidelines.

## License

Apache-2.0

---

<div align="center">

<sub>Part of <a href="https://github.com/pulseengine">PulseEngine</a> &mdash; formally verified WebAssembly toolchain for safety-critical systems</sub>

</div>
