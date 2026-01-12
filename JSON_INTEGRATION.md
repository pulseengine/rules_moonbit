# Bazel-MoonBit JSON Integration

This document explains the JSON-based integration between Bazel and MoonBit that maintains hermeticity while enabling rich communication between the two build systems.

## Overview

The integration uses JSON as an intermediate format to:

1. **Preserve Hermeticity**: All build information is explicitly declared in JSON files
2. **Enable Rich Communication**: Complex build configurations can be passed between systems
3. **Maintain Dependency Tracking**: Full dependency graphs are preserved in JSON format
4. **Support Multiple Platforms**: Platform-specific configurations are handled via JSON

## Architecture

```
Bazel → [JSON Config] → MoonBit Compiler → [JSON Metadata] → Bazel
```

### Key Components

1. **JSON Configuration Files** (Bazel → MoonBit):
   - `*.moon.build.json`: Main build configuration
   - `*.moon.hermetic.json`: Hermetic build settings
   - `*.moon.deps.json`: Dependency manifest

2. **JSON Metadata Files** (MoonBit → Bazel):
   - `*.moon.metadata.json`: Build output metadata
   - `*.moon.test.report.json`: Test results and coverage

## JSON Configuration Format

### Build Configuration (`*.moon.build.json`)

```json
{
  "bazel": {
    "label": "//package:target",
    "workspace_name": "workspace",
    "package_name": "package",
    "target_name": "target",
    "is_main": false,
    "is_test": false,
    "platform": "darwin_arm64",
    "configuration": "release"
  },
  "sources": ["source1.mbt", "source2.mbt"],
  "dependencies": [
    {
      "label": "//other:dep",
      "package": "other",
      "name": "dep",
      "metadata": {}
    }
  ],
  "options": {
    "target": "wasm",
    "optimization": "release",
    "debug_info": false,
    "output_format": "json"
  }
}
```

### Hermetic Configuration (`*.moon.hermetic.json`)

```json
{
  "hermetic_build": {
    "bazel_version": "7.0.0",
    "moonbit_version": "0.6.33",
    "platform": {
      "os": "darwin",
      "arch": "arm64",
      "cpu": "apple_arm64"
    },
    "toolchain": {
      "type": "hermetic",
      "source": "bazel_vendor",
      "checksum": "verified"
    },
    "target": "wasm",
    "output": "output.wasm",
    "timestamp": "2026-01-11T00:00:00Z",
    "build_id": "target_hash"
  }
}
```

### Dependency Manifest (`*.moon.deps.json`)

```json
{
  "dependencies": [
    {
      "label": "//other:dep",
      "package": "other",
      "name": "dep"
    }
  ],
  "transitive_dependencies": [
    {
      "label": "//base:lib",
      "package": "base",
      "name": "lib"
    }
  ],
  "dependency_graph": {
    "//other:dep": {
      "direct": true,
      "transitive": ["//base:lib"]
    }
  }
}
```

## Metadata Format (MoonBit → Bazel)

```json
{
  "moonbit": {
    "version": "0.6.33",
    "target": "wasm",
    "optimization_level": "release"
  },
  "dependencies": ["//other:dep"],
  "outputs": ["output.wasm"],
  "warnings": [],
  "errors": [],
  "timing": {
    "compile_time_ms": 100,
    "optimization_time_ms": 50,
    "total_time_ms": 150
  }
}
```

## Hermeticity Guarantees

The JSON integration maintains hermeticity through:

1. **Explicit Toolchain Declaration**: All tools are specified in JSON configs
2. **Checksum Verification**: Toolchain checksums are included in hermetic configs
3. **Complete Dependency Tracking**: Full dependency graphs are preserved
4. **Platform Specification**: Target platforms are explicitly declared
5. **Environment Isolation**: Build environment is fully specified in JSON

## Build Process Flow

1. **Bazel Analysis Phase**:
   - Bazel analyzes the build graph
   - Generates JSON configuration files for each MoonBit target
   - Declares all inputs and outputs explicitly

2. **MoonBit Compilation Phase**:
   - MoonBit reads JSON configuration files
   - Performs compilation with specified settings
   - Generates JSON metadata about the build

3. **Bazel Execution Phase**:
   - Bazel reads MoonBit's JSON metadata
   - Updates dependency graph with build information
   - Provides outputs to dependent targets

## Example Usage

```python
# In your BUILD.bazel file
moonbit_library(
    name = "my_lib",
    srcs = ["lib.mbt"],
    deps = [":other_lib"],
)

moonbit_binary(
    name = "my_bin",
    srcs = ["main.mbt"],
    deps = [":my_lib"],
)
```

This will generate:
- `my_lib.moon.build.json` - Build configuration
- `my_lib.moon.hermetic.json` - Hermetic settings  
- `my_lib.moon.deps.json` - Dependency manifest
- `my_lib.moon.metadata.json` - Build metadata

## Benefits

1. **Hermetic Builds**: All build information is explicitly declared
2. **Cross-Platform Support**: Platform configurations are handled via JSON
3. **Rich Metadata**: Detailed build information is preserved
4. **Debugging Support**: Full build logs and timing information
5. **Toolchain Flexibility**: Multiple toolchain versions can be supported

## Implementation Details

The integration is implemented in:
- `moonbit/private/json_utils.bzl` - JSON generation and parsing
- `moonbit/private/compilation.bzl` - Compilation actions with JSON
- `moonbit/private/toolchain.bzl` - Toolchain management with JSON metadata

See the example in `examples/json_integration/` for a complete working example.