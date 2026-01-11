# Cross-Compilation Support Plan for Rules_Moonbit

## Overview

This document outlines the comprehensive plan for implementing cross-compilation support in rules_moonbit, enabling compilation from one platform to another (e.g., compiling on macOS for Linux targets).

## Current State

Currently, rules_moonbit supports:
- Native compilation (compiling for the current platform)
- Basic platform detection
- Single toolchain management

## Target State

The goal is to support:
- Cross-compilation between all major platforms
- Platform-specific toolchains
- Target platform specification
- Multi-platform builds

## Architecture

```
┌───────────────────────────────────────────────────────┐
│                 Cross-Compilation Architecture          │
├───────────────────────────────────────────────────────┤
│                                                       │
│  ┌─────────────────┐    ┌─────────────────────────┐  │
│  │  Host           │    │  Target                │  │
│  │  Platform       │    │  Platform              │  │
│  └─────────────────┘    └─────────────────────────┘  │
│          │                      │                   │
│          ▼                      ▼                   │
│  ┌─────────────────┐    ┌─────────────────────────┐  │
│  │  Host           │    │  Target                │  │
│  │  Toolchain      │    │  Toolchain             │  │
│  └─────────────────┘    └─────────────────────────┘  │
│          │                      │                   │
│          ▼                      ▼                   │
│  ┌─────────────────────────────────────────────────┐  │
│  │  Cross-Compilation                             │  │
│  │  Configuration & Management                   │  │
│  └─────────────────────────────────────────────────┘  │
│                  │                                    │
│                  ▼                                    │
│  ┌─────────────────────────────────────────────────┐  │
│  │  MoonBit Compilation                           │  │
│  │  with Cross-Compilation Flags                  │  │
│  └─────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Platform Abstraction (Week 1-2)

**Objective**: Create platform abstraction layer for cross-compilation

**Tasks**:
1. **Platform Definitions**: Define supported platforms and their properties
   - `darwin_arm64`, `darwin_amd64`
   - `linux_arm64`, `linux_amd64`
   - `windows_amd64`
   - Platform capabilities and constraints

2. **Platform Detection**: Enhance platform detection
   - Host platform detection
   - Target platform specification
   - Platform compatibility matrix

3. **Toolchain Management**: Support multiple toolchains
   - Host toolchain (for native compilation)
   - Target toolchain (for cross-compilation)
   - Toolchain resolution based on target

**Deliverables**:
- `moonbit/platforms/defs.bzl` - Platform definitions
- Enhanced platform detection in toolchain
- Multi-toolchain support

### Phase 2: Cross-Compilation Configuration (Week 3-4)

**Objective**: Implement cross-compilation configuration system

**Tasks**:
1. **Target Platform Specification**: Add target platform attributes
   - `target_platform` attribute for rules
   - Platform constraints and validation
   - Default platform resolution

2. **Toolchain Resolution**: Implement target-aware toolchain resolution
   - Toolchain selection based on target platform
   - Fallback mechanisms
   - Error handling for unsupported targets

3. **Configuration Propagation**: Propagate configuration through dependency graph
   - Ensure all dependencies use same target platform
   - Validate platform compatibility
   - Handle mixed-platform scenarios

**Deliverables**:
- Enhanced rule attributes with target platform support
- Toolchain resolution logic
- Configuration validation

### Phase 3: Cross-Compilation Execution (Week 5-6)

**Objective**: Implement actual cross-compilation execution

**Tasks**:
1. **MoonBit Cross-Compilation Flags**: Add cross-compilation flags to MoonBit invocation
   - `--target` flag for MoonBit compiler
   - Platform-specific compilation flags
   - Architecture-specific optimizations

2. **Cross-Compilation Actions**: Create cross-compilation actions
   - Platform-specific compilation actions
   - Target-aware input/output handling
   - Cross-platform dependency management

3. **Artifact Management**: Handle cross-compiled artifacts
   - Platform-specific output directories
   - Artifact naming conventions
   - Platform-specific packaging

**Deliverables**:
- Cross-compilation action creation
- Platform-specific compilation flags
- Artifact management system

### Phase 4: Testing and Validation (Week 7-8)

**Objective**: Comprehensive testing of cross-compilation functionality

**Tasks**:
1. **Unit Tests**: Test individual components
   - Platform detection tests
   - Toolchain resolution tests
   - Configuration propagation tests

2. **Integration Tests**: Test cross-compilation workflows
   - Native → Native compilation
   - Native → Cross compilation
   - Multi-platform builds

3. **Validation Tests**: Validate cross-compiled outputs
   - Verify cross-compiled binaries
   - Test cross-platform compatibility
   - Validate platform-specific behavior

**Deliverables**:
- Comprehensive test suite
- Validation framework
- Test documentation

## Technical Details

### Platform Definitions

```python
# Example platform definitions
PLATFORMS = {
    "darwin_arm64": {
        "os": "darwin",
        "arch": "arm64",
        "triple": "aarch64-apple-darwin",
        "extensions": [".dylib", ".framework"],
        "executable_ext": "",
    },
    "linux_amd64": {
        "os": "linux",
        "arch": "amd64",
        "triple": "x86_64-unknown-linux-gnu",
        "extensions": [".so", ".a"],
        "executable_ext": "",
    },
    "windows_amd64": {
        "os": "windows",
        "arch": "amd64",
        "triple": "x86_64-pc-windows-msvc",
        "extensions": [".dll", ".lib"],
        "executable_ext": ".exe",
    },
}
```

### Cross-Compilation Rule Attributes

```python
moonbit_library(
    name = "mylib",
    srcs = ["lib.mbt"],
    deps = [":otherlib"],
    target_platform = "linux_amd64",  # Cross-compile for Linux
    host_platform = "auto",          # Auto-detect host platform
)
```

### Toolchain Resolution Logic

```python
def resolve_toolchain(ctx, target_platform):
    """Resolve appropriate toolchain for target platform"""
    
    # 1. Check if target platform matches host platform
    host_platform = ctx.platform
    if target_platform == host_platform:
        return get_native_toolchain()
    
    # 2. Look for pre-configured cross-compilation toolchain
    cross_toolchain = get_cross_toolchain(target_platform)
    if cross_toolchain:
        return cross_toolchain
    
    # 3. Fallback: download or configure cross-compilation toolchain
    return configure_cross_toolchain(target_platform)
```

### Cross-Compilation Action Creation

```python
def create_cross_compilation_action(ctx, target_platform):
    """Create cross-compilation action with target-specific flags"""
    
    # Get target platform info
    platform_info = PLATFORMS[target_platform]
    
    # Build compilation command
    args = [
        "moon", "build",
        "--target", platform_info["triple"],
        "--arch", platform_info["arch"],
        "--os", platform_info["os"],
    ]
    
    # Add platform-specific flags
    if target_platform == "windows_amd64":
        args.extend(["--windows", "--msvc"])
    elif target_platform.startswith("darwin"):
        args.extend(["--macos", "--apple"])
    
    # Create action
    ctx.actions.run(
        mnemonic = "MoonbitCrossCompile",
        executable = "moon",
        arguments = args,
        # ...
    )
```

## Implementation Roadmap

### Short-Term (Next 2 Weeks)
1. ✅ Implement platform definitions
2. ✅ Add target platform attributes
3. ✅ Basic toolchain resolution
4. ✅ Cross-compilation configuration

### Medium-Term (Next 1-2 Months)
1. Implement cross-compilation actions
2. Add platform-specific flags
3. Enhance artifact management
4. Comprehensive testing

### Long-Term (Future Enhancements)
1. Cross-compilation caching
2. Remote execution support
3. Platform-specific optimizations
4. Advanced debugging support

## Success Criteria

### Phase 1 Success
- Platform definitions implemented
- Basic cross-compilation configuration working
- Toolchain resolution functional

### Phase 2 Success
- Cross-compilation builds working for major platforms
- Configuration properly propagated through dependencies
- Basic validation tests passing

### Phase 3 Success
- All cross-compilation scenarios working
- Platform-specific optimizations implemented
- Comprehensive test coverage
- Production-ready for major use cases

### Phase 4 Success
- Full test suite passing
- Cross-compilation validated on all supported platforms
- Documentation complete
- Ready for general availability

## Risks and Mitigations

### Technical Risks
1. **MoonBit Cross-Compilation Support**: MoonBit may have limited cross-compilation capabilities
   - *Mitigation*: Work with MoonBit team, implement workarounds if needed

2. **Platform-Specific Issues**: Different platforms may have unique requirements
   - *Mitigation*: Incremental testing, platform-specific configurations

3. **Performance Impact**: Cross-compilation may be slower than native compilation
   - *Mitigation*: Implement caching, optimize build process

### Operational Risks
1. **Toolchain Management Complexity**: Managing multiple toolchains can be complex
   - *Mitigation*: Automate toolchain setup, provide clear documentation

2. **Testing Complexity**: Testing all platform combinations is resource-intensive
   - *Mitigation*: Prioritize major platforms, use CI/CD for automated testing

3. **User Adoption**: Users may be unfamiliar with cross-compilation concepts
   - *Mitigation*: Provide examples, documentation, and migration guides

## Monitoring and Maintenance

### Health Metrics
1. Cross-compilation success rate
2. Build performance metrics
3. Platform coverage
4. Test coverage

### Maintenance Tasks
1. Regular platform compatibility testing
2. Update platform definitions for new releases
3. Monitor MoonBit cross-compilation support
4. Update documentation and examples

## Conclusion

This comprehensive plan outlines the implementation of cross-compilation support in rules_moonbit, following a phased approach that ensures robustness and compatibility. The implementation will provide users with powerful cross-compilation capabilities while maintaining the simplicity and reliability of the existing system.
