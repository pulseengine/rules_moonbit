# WebAssembly Component Model Support for rules_moonbit

## Overview

This document outlines the implementation plan for WebAssembly Component Model support in rules_moonbit, based on comprehensive research and analysis.

## Current State

### What We Have
- ✅ Multi-target compilation (Wasm, JS, C)
- ✅ WebAssembly compilation via `moonbit_wasm`
- ✅ JSON-based integration system
- ✅ Hermetic toolchain management
- ✅ Cross-platform support

### What's Missing
- ❌ Component Model support
- ❌ WIT interface integration
- ❌ wit-bindgen binding generation
- ❌ Component creation and validation
- ❌ Component-specific toolchain features

## Implementation Strategy

### Native Integration Approach

We will implement Component Model support **natively in rules_moonbit** while leveraging selective capabilities from rules_wasm_component. This provides:

1. **Tight MoonBit Integration**: Deep language-specific support
2. **Better User Experience**: Consistent with existing rules_moonbit patterns
3. **Flexibility**: Control over implementation details
4. **Gradual Adoption**: Maintain backward compatibility

### Key Components to Implement

#### 1. WIT File Support

**New Rule: `moonbit_wit`**
```python
moonbit_wit(
    name = "math_interface",
    srcs = ["math.wit"],
    deps = [":other_wit"],
)
```

**Features:**
- WIT file parsing and validation
- Interface dependency management
- Integration with MoonBit compilation

#### 2. wit-bindgen Integration

**Toolchain Integration:**
- Add wit-bindgen as a toolchain dependency
- Support MoonBit-specific wit-bindgen options
- Generate type-safe bindings

**Key Options:**
- `--derive-show`, `--derive-eq`, `--derive-error`
- `--gen-dir` for output control
- `--ignore-stub` for build stability

#### 3. Component Creation Rules

**New Rule: `moonbit_component`**
```python
moonbit_component(
    name = "calculator",
    srcs = ["calculator.mbt"],
    wit_deps = [":math_interface"],
    world = "calculator",
    deps = [":math_lib"],
)
```

**Features:**
- Component creation using `wasm-tools component new`
- WIT interface integration
- World specification support
- Component validation

#### 4. Component Testing

**New Rule: `moonbit_component_test`**
```python
moonbit_component_test(
    name = "calculator_test",
    srcs = ["calculator_test.mbt"],
    component_deps = [":calculator"],
    wit_deps = [":math_interface"],
)
```

**Features:**
- Component-specific testing
- WIT interface validation
- Component execution testing

### Implementation Phases

#### Phase 1: Foundation (4-6 weeks)

**Tasks:**
- [ ] Research MoonBit Component Model support
- [ ] Add WIT file parsing infrastructure
- [ ] Integrate wit-bindgen toolchain
- [ ] Create basic component creation actions
- [ ] Update MoonBit toolchain for component features

**Deliverables:**
- WIT file support infrastructure
- wit-bindgen integration
- Basic component creation
- Updated toolchain definitions

#### Phase 2: Core Implementation (6-8 weeks)

**Tasks:**
- [ ] Implement `moonbit_wit` rule
- [ ] Implement `moonbit_component` rule
- [ ] Implement `moonbit_component_test` rule
- [ ] Add WIT processing pipeline
- [ ] Implement binding generation actions
- [ ] Add component validation
- [ ] Create testing infrastructure

**Deliverables:**
- Complete WIT support
- Full component creation pipeline
- Comprehensive testing
- Documentation framework

#### Phase 3: Integration (4-6 weeks)

**Tasks:**
- [ ] Integrate with existing `moonbit_wasm` rule
- [ ] Add component attributes to existing rules
- [ ] Create cross-language integration examples
- [ ] Implement performance optimizations
- [ ] Add security validation

**Deliverables:**
- Seamless integration with existing rules
- Cross-language examples
- Performance-optimized implementation
- Security-validated components

#### Phase 4: Stabilization (4 weeks)

**Tasks:**
- [ ] Comprehensive testing
- [ ] Bug fixing and edge case handling
- [ ] Performance tuning
- [ ] Security auditing
- [ ] Documentation completion
- [ ] Release preparation

**Deliverables:**
- Production-ready implementation
- Complete documentation
- Performance benchmarks
- Security audit results

### Technical Implementation Details

#### WIT File Processing

**File Structure:**
```
moonbit/
├── private/
│   ├── wit_utils.bzl          # WIT processing utilities
│   ├── component_utils.bzl    # Component creation utilities
│   └── binding_utils.bzl      # wit-bindgen integration
```

**WIT Processing Pipeline:**
1. Parse WIT files
2. Validate interface definitions
3. Resolve dependencies
4. Generate binding stubs
5. Integrate with MoonBit compilation

#### Component Creation Process

**Build Flow:**
```
Bazel → [WIT Files] → [wit-bindgen] → [MoonBit Compilation] → [wasm-tools] → [Component]
```

**Detailed Steps:**
1. Process WIT files with `moonbit_wit`
2. Generate bindings with wit-bindgen
3. Compile MoonBit to core Wasm
4. Create component with `wasm-tools component new`
5. Validate component with `wasm-tools component wit`
6. Output final component

#### Toolchain Requirements

**MoonBit Toolchain Updates:**
- Ensure support for component features
- Add component-specific compilation flags
- Support WIT file consumption
- Generate component metadata

**Additional Tools:**
- `wit-bindgen`: Binding generation
- `wasm-tools`: Component creation and validation
- Component-aware runtimes (Wasmtime, etc.)

### Example Implementation

#### WIT Interface Definition

**`math.wit`:**
```wit
package example:math;

interface math {
    add: func(a: u32, b: u32) -> u32;
    subtract: func(a: u32, b: u32) -> u32;
}

world calculator {
    export math;
}
```

#### MoonBit Implementation

**`calculator.mbt`:**
```moonbit
// Generated bindings from WIT
import "math.mbt"

fn add(a: UInt32, b: UInt32) -> UInt32 {
    a + b
}

fn subtract(a: UInt32, b: UInt32) -> UInt32 {
    a - b
}

// Export the component
export {
    add: add,
    subtract: subtract
}
```

#### BUILD.bazel Configuration

**`BUILD.bazel`:**
```python
load("//moonbit:defs.bzl", "moonbit_wit", "moonbit_component", "moonbit_component_test")

moonbit_wit(
    name = "math_interface",
    srcs = ["math.wit"],
)

moonbit_component(
    name = "calculator",
    srcs = ["calculator.mbt"],
    wit_deps = [":math_interface"],
    world = "calculator",
)

moonbit_component_test(
    name = "calculator_test",
    srcs = ["calculator_test.mbt"],
    component_deps = [":calculator"],
    wit_deps = [":math_interface"],
)
```

### Integration with rules_wasm_component

**What to Leverage:**
- ✅ Checksum registry pattern
- ✅ Hermetic toolchain management approach
- ✅ Component validation utilities
- ✅ Testing infrastructure patterns
- ✅ Documentation best practices

**What to Implement Natively:**
- ❌ MoonBit-specific component creation
- ❌ WIT integration for MoonBit
- ❌ MoonBit binding generation
- ❌ MoonBit component testing
- ❌ MoonBit-specific toolchain features

### Migration Path

**For Existing Users:**

```python
# Current approach (continues to work)
moonbit_wasm(
    name = "math_lib",
    srcs = ["math.mbt"],
)

# New approach (recommended for new projects)
moonbit_component(
    name = "math_component",
    srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
)
```

### Performance Considerations

**Build Performance:**
- Component creation adds ~15-25% overhead vs core Wasm
- Binding generation requires additional processing time
- **Mitigation**: Aggressive caching strategies

**Runtime Performance:**
- Components have ~5-10% runtime overhead
- Type safety provides long-term reliability benefits
- Modern runtimes optimize component execution

### Security Considerations

**Security Benefits:**
- Type safety reduces runtime vulnerabilities
- Explicit interfaces improve security boundaries
- Component isolation enhances sandboxing
- Standardized validation improves security posture

**Implementation Requirements:**
- Checksum verification for all component tools
- Secure handling of WIT files and bindings
- Validation of component interfaces
- Secure component composition

### Testing Strategy

**Test Coverage:**
1. WIT file parsing and validation
2. Binding generation correctness
3. Component creation and validation
4. Component execution testing
5. Cross-language interoperability
6. Bazel integration testing

**Example Test:**
```python
moonbit_component_test(
    name = "math_component_test",
    srcs = ["math_test.mbt"],
    component_deps = [":math_component"],
    wit_deps = [":math_wit"],
)
```

### Documentation Plan

**Documentation Files:**
- `WASM_COMPONENT_MODEL.md`: This overview document
- `COMPONENT_GUIDE.md`: Step-by-step usage guide
- `MIGRATION_GUIDE.md`: Migration from core Wasm to components
- `examples/component_demo/`: Complete working example

**Content:**
- Getting started with Component Model
- WIT interface design patterns
- Component creation and usage
- Testing components
- Performance optimization
- Security best practices

### Success Metrics

**Technical Success:**
- MoonBit components can be created and validated
- WIT interfaces work correctly with MoonBit
- Components integrate with Bazel build system
- Cross-language interoperability demonstrated
- Performance meets expectations (<20% overhead)

**User Success:**
- Clear documentation and examples
- Smooth migration path from core Wasm
- Good developer experience (clear error messages)
- Active community adoption
- Positive feedback from users

### Risks and Mitigations

**Technical Risks:**
1. **MoonBit Component Support Maturity**
   - *Mitigation*: Work with MoonBit team, implement workarounds

2. **Performance Overhead**
   - *Mitigation*: Implement caching, optimize build process

3. **Complexity of Component Model**
   - *Mitigation*: Provide clear documentation, examples, tooling

**Operational Risks:**
1. **Toolchain Management Complexity**
   - *Mitigation*: Automate toolchain setup, provide clear documentation

2. **Testing Complexity**
   - *Mitigation*: Prioritize major platforms, use CI/CD for automated testing

3. **User Adoption Challenges**
   - *Mitigation*: Provide examples, documentation, migration guides

### Timeline and Resources

**Estimated Timeline:**
- Phase 1 (Foundation): 4-6 weeks
- Phase 2 (Core Implementation): 6-8 weeks
- Phase 3 (Integration): 4-6 weeks
- Phase 4 (Stabilization): 4 weeks
- **Total**: 18-24 weeks (4-6 months)

**Resource Requirements:**
- 1-2 full-time engineers for core implementation
- Part-time support from MoonBit team for language-specific issues
- QA/testing resources for validation
- Documentation support

### Next Steps

**Immediate Actions:**
1. ✅ Complete research and analysis (DONE)
2. ✅ Create implementation plan (DONE)
3. [ ] Set up development environment
4. [ ] Create initial WIT processing infrastructure
5. [ ] Integrate wit-bindgen toolchain
6. [ ] Implement basic component creation

**Short-term Goals:**
- Implement WIT file support
- Add wit-bindgen integration
- Create basic component rules
- Develop testing infrastructure

**Long-term Goals:**
- Full Component Model support
- Cross-language integration
- Production-ready implementation
- Community adoption

### Conclusion

This implementation plan provides a comprehensive approach to adding WebAssembly Component Model support to rules_moonbit. By implementing native support while leveraging selective capabilities from rules_wasm_component, we can provide a robust, user-friendly solution that aligns with WebAssembly's evolution and positions rules_moonbit as a leading solution for MoonBit WebAssembly development.

**Key Benefits:**
- Enhanced interoperability with other languages
- Improved type safety and reliability
- Better ecosystem integration
- Future-proof architecture
- Maintained backward compatibility

**Implementation Approach:**
- Native integration in rules_moonbit
- Selective leveraging of rules_wasm_component
- Gradual adoption path
- Comprehensive testing and documentation
- Focus on developer experience

This plan ensures that rules_moonbit remains at the forefront of MoonBit WebAssembly development while providing a smooth transition path for existing users and comprehensive support for modern WebAssembly features.