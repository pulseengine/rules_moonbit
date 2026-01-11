# Rules_Moonbit

Bazel rules for building MoonBit projects.

## Status

This project is in the early development phase. The goal is to create Bazel rules that integrate with MoonBit's build system while maintaining Bazel's core principles.

## Getting Started

### Prerequisites

- Bazel (latest version)
- MoonBit toolchain installed
- Basic understanding of Bazel and MoonBit

### Quick Start

1. Add rules_moonbit to your WORKSPACE:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_moonbit",
    urls = ["https://github.com/your-repo/rules_moonbit/releases/download/v0.1.0/rules_moonbit-v0.1.0.tar.gz"],
    sha256 = "...",
)

load("@rules_moonbit//moonbit:defs.bzl", "moonbit_register_toolchains")
moonbit_register_toolchains()
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

## Development

### Repository Structure

```
moonbit/
├── defs.bzl                # Public API
├── private/                # Internal implementation
│   ├── moon.bzl            # Core rules
│   ├── toolchain.bzl       # Toolchain implementation
│   └── package.bzl         # Package analysis
├── providers.bzl           # MoonBit providers
└── examples/              # Usage examples
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
