# WebAssembly Component Model Delegation Strategy

## Revised Approach: Delegation to rules_wasm_component

After careful reconsideration, we are adopting a **delegation approach** where WebAssembly Component Model support is handled by `rules_wasm_component` while `rules_moonbit` focuses on MoonBit-specific compilation and integration.

## Rationale

### Why This Approach Makes Sense

1. **Toolchain Ownership**: `rules_wasm_component` already owns and manages Bytecode Alliance tools
2. **Expertise Concentration**: Component Model tools (wit-bindgen, wasm-tools) are better maintained in one place
3. **Ecosystem Consistency**: Other language rules can leverage the same Component Model infrastructure
4. **Reduced Duplication**: Avoid implementing Component Model support in multiple rulesets
5. **Better Maintenance**: Single point of maintenance for Component Model toolchain

### What Belongs Where

**rules_wasm_component (Component Model Expert):**
- ✅ wit-bindgen integration and management
- ✅ wasm-tools component creation
- ✅ Component validation and testing
- ✅ WIT file processing infrastructure
- ✅ Component toolchain management
- ✅ Cross-language Component Model support

**rules_moonbit (MoonBit Language Expert):**
- ✅ MoonBit-specific compilation
- ✅ Multi-target support (Wasm, JS, C)
- ✅ MoonBit toolchain management
- ✅ Integration with rules_wasm_component
- ✅ MoonBit-specific build rules
- ✅ Language-specific optimization

## Integration Architecture

```
rules_moonbit → [MoonBit Wasm] → rules_wasm_component → [Component]
```

### Build Flow

1. **MoonBit Compilation**: rules_moonbit compiles MoonBit to core WebAssembly
2. **Component Conversion**: rules_wasm_component converts Wasm to Component Model
3. **Integration**: rules_moonbit provides seamless integration with Component Model

### Rule Interaction

```python
# rules_moonbit: Compile MoonBit to Wasm
moonbit_wasm(
    name = "math_core",
    srcs = ["math.mbt"],
)

# rules_wasm_component: Convert to Component Model
wasm_component(
    name = "math_component",
    srcs = [":math_core"],
    wit_deps = [":math_wit"],
)

# rules_moonbit: Provide integrated rule (convenience)
moonbit_component(
    name = "math_full",
    srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
)
```

## Implementation Strategy

### Phase 1: rules_wasm_component Enhancement (rules_wasm_component repo)

**Required Features:**
1. **MoonBit-Specific Component Creation**
   - Support MoonBit-generated Wasm modules
   - Handle MoonBit-specific metadata
   - Provide MoonBit-optimized component creation

2. **WIT Integration for MoonBit**
   - MoonBit-compatible WIT processing
   - MoonBit binding generation patterns
   - MoonBit interface validation

3. **MoonBit Toolchain Integration**
   - MoonBit compiler compatibility
   - MoonBit-specific component flags
   - MoonBit optimization support

4. **Testing Infrastructure**
   - MoonBit component testing support
   - Component validation for MoonBit outputs
   - Integration testing patterns

### Phase 2: rules_moonbit Integration (this repo)

**Integration Points:**
1. **Component Creation Wrapper**
   - `moonbit_component` rule that delegates to `wasm_component`
   - MoonBit-specific convenience features
   - Seamless integration with MoonBit build system

2. **WIT File Support**
   - WIT file processing for MoonBit
   - Integration with rules_wasm_component WIT rules
   - MoonBit-specific WIT validation

3. **Toolchain Integration**
   - Ensure MoonBit toolchain works with Component Model
   - Component-specific compilation flags
   - MoonBit optimization for components

4. **Testing Integration**
   - MoonBit component testing rules
   - Integration with rules_wasm_component testing
   - MoonBit-specific test patterns

### Phase 3: Documentation and Examples

**Documentation Required:**
1. **Integration Guide**: How to use rules_moonbit with rules_wasm_component
2. **Migration Guide**: Moving from core Wasm to Component Model
3. **Examples**: Complete working examples of the integration
4. **Troubleshooting**: Common issues and solutions

## Specific Implementation Details

### rules_wasm_component Requirements

**New Rules Needed:**
```python
# Enhanced component rule with MoonBit support
wasm_component(
    name = "component",
    srcs = [":moonbit_wasm"],  # Accept MoonBit Wasm output
    wit_deps = [":wit_files"],
    moonbit_specific = True,  # MoonBit optimization flag
)

# MoonBit-optimized component creation
moonbit_optimized_component(
    name = "optimized",
    srcs = [":moonbit_wasm"],
    wit_deps = [":wit_files"],
    optimization_level = "aggressive",
)
```

**Toolchain Enhancements:**
- MoonBit compiler version detection
- MoonBit-specific component flags
- MoonBit optimization profiles
- MoonBit metadata handling

### rules_moonbit Integration

**Integration Rules:**
```python
# Convenience rule that delegates to rules_wasm_component
moonbit_component(
    name = "math_component",
    srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
    # Internally: compiles to Wasm, then delegates to wasm_component
)

# Direct integration with rules_wasm_component
moonbit_to_wasm_component(
    name = "direct_component",
    moonbit_srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
    # Uses rules_wasm_component directly
)
```

**Implementation:**
```python
def _moonbit_component_impl(ctx):
    # Step 1: Compile MoonBit to Wasm
    wasm_output = compile_moonbit_to_wasm(ctx)
    
    # Step 2: Delegate to rules_wasm_component
    component_output = create_wasm_component(
        ctx,
        wasm_src = wasm_output,
        wit_deps = ctx.attr.wit_deps,
        moonbit_specific = True
    )
    
    return [MoonbitComponentInfo(
        component = component_output,
        wasm_core = wasm_output,
        wit_interfaces = ctx.attr.wit_deps,
    )]
```

## Benefits of This Approach

### For rules_moonbit
1. **Focus on Core Strengths**: MoonBit language expertise
2. **Reduced Maintenance**: No need to maintain Component Model tools
3. **Better Integration**: Leverage rules_wasm_component expertise
4. **Consistency**: Same Component Model infrastructure as other languages
5. **Future-Proof**: Automatically benefit from rules_wasm_component improvements

### For rules_wasm_component
1. **Expanded Usage**: More languages using the Component Model support
2. **Better Testing**: MoonBit provides additional test coverage
3. **Ecosystem Growth**: Strengthens the Component Model ecosystem
4. **Cross-Language**: Consistent Component Model support across languages
5. **Toolchain Reuse**: Single toolchain management for all languages

### For Users
1. **Consistent Experience**: Same Component Model patterns across languages
2. **Better Documentation**: Unified Component Model documentation
3. **Easier Debugging**: Common toolchain and error patterns
4. **Cross-Language**: Easier to mix MoonBit with other languages
5. **Future-Proof**: Automatic access to new Component Model features

## Migration Path

### Current Users (Core Wasm)
```python
# Current approach continues to work
moonbit_wasm(
    name = "math_lib",
    srcs = ["math.mbt"],
)
```

### New Component Model Users
```python
# New approach using integration
moonbit_component(
    name = "math_component",
    srcs = ["math.mbt"],
    wit_deps = [":math_wit"],
)
```

### Advanced Users (Direct Integration)
```python
# Direct use of rules_wasm_component
load("@rules_wasm_component//wasm:defs.bzl", "wasm_component")

wasm_component(
    name = "math_component",
    srcs = [":math_wasm"],
    wit_deps = [":math_wit"],
)
```

## Implementation Roadmap

### rules_wasm_component Enhancements (Separate Repo)

**Timeline: 6-8 weeks**

1. **Week 1-2**: Research MoonBit Component Model requirements
2. **Week 3-4**: Add MoonBit-specific component creation
3. **Week 5-6**: Implement MoonBit WIT integration
4. **Week 7-8**: Add MoonBit toolchain support and testing

**Deliverables:**
- MoonBit-compatible component rules
- MoonBit WIT processing
- MoonBit toolchain integration
- MoonBit component testing
- Documentation and examples

### rules_moonbit Integration (This Repo)

**Timeline: 4-6 weeks**

1. **Week 1-2**: Create integration layer with rules_wasm_component
2. **Week 3-4**: Implement convenience rules and testing
3. **Week 5-6**: Create documentation and examples

**Deliverables:**
- `moonbit_component` convenience rule
- Integration with rules_wasm_component
- Testing infrastructure
- Documentation and examples
- Migration guides

### Joint Testing and Stabilization

**Timeline: 4 weeks**

1. **Week 1-2**: Cross-repo integration testing
2. **Week 3-4**: Performance optimization and bug fixing

**Deliverables:**
- Production-ready integration
- Performance benchmarks
- Comprehensive test coverage
- Release documentation

## Technical Requirements

### rules_wasm_component Requirements

**Toolchain:**
- wit-bindgen with MoonBit support
- wasm-tools with MoonBit compatibility
- MoonBit compiler version detection
- MoonBit-specific component flags

**Rules:**
- MoonBit-aware component creation
- MoonBit WIT file processing
- MoonBit optimization profiles
- MoonBit component validation

**Testing:**
- MoonBit component test patterns
- MoonBit integration testing
- MoonBit performance benchmarks

### rules_moonbit Requirements

**Integration:**
- Dependency on rules_wasm_component
- MoonBit to Wasm compilation
- Component creation delegation
- WIT file support

**Rules:**
- `moonbit_component` convenience rule
- Integration testing rules
- Documentation and examples

**Testing:**
- Integration testing with rules_wasm_component
- MoonBit-specific component testing
- Performance validation

## Documentation Plan

### rules_wasm_component Documentation
- MoonBit Component Model guide
- MoonBit-specific WIT patterns
- MoonBit component creation examples
- MoonBit toolchain configuration

### rules_moonbit Documentation
- Component Model integration guide
- Migration from core Wasm to components
- MoonBit component examples
- Troubleshooting and FAQ

### Joint Documentation
- Cross-repo integration guide
- Component Model best practices
- Performance optimization guide
- Security considerations

## Success Criteria

### Technical Success
- MoonBit components can be created using rules_wasm_component
- rules_moonbit integrates seamlessly with rules_wasm_component
- Component creation works across all supported platforms
- Performance meets expectations (<20% overhead vs core Wasm)
- All tests pass with good coverage

### User Success
- Clear documentation for both repos
- Smooth migration path from core Wasm
- Good developer experience with clear error messages
- Active community adoption
- Positive feedback from users

### Ecosystem Success
- rules_wasm_component becomes the standard for Component Model
- rules_moonbit provides excellent MoonBit integration
- Other language rules follow the same pattern
- WebAssembly Component Model ecosystem grows

## Risks and Mitigations

### Technical Risks
1. **Integration Complexity**
   - *Mitigation*: Start with simple integration, add complexity gradually

2. **Performance Overhead**
   - *Mitigation*: Implement caching, optimize build process

3. **Toolchain Compatibility**
   - *Mitigation*: Work with MoonBit team, implement compatibility layers

### Operational Risks
1. **Cross-Repo Coordination**
   - *Mitigation*: Regular sync meetings, clear interfaces

2. **Testing Complexity**
   - *Mitigation*: Focus on integration testing, use CI/CD

3. **User Adoption**
   - *Mitigation*: Provide clear documentation, migration guides, examples

## Recommendations

### For rules_wasm_component Team
1. **Add MoonBit-Specific Features**:
   - MoonBit compiler detection
   - MoonBit optimization profiles
   - MoonBit metadata handling

2. **Enhance Documentation**:
   - MoonBit Component Model guide
   - MoonBit integration examples
   - MoonBit troubleshooting guide

3. **Improve Testing**:
   - MoonBit component test patterns
   - MoonBit integration tests
   - MoonBit performance benchmarks

### For rules_moonbit Team
1. **Focus on Integration**:
   - Clean delegation to rules_wasm_component
   - MoonBit-specific convenience features
   - Excellent user experience

2. **Maintain Simplicity**:
   - Keep rules_moonbit focused on MoonBit
   - Avoid duplicating Component Model logic
   - Leverage rules_wasm_component expertise

3. **Document Clearly**:
   - Integration guide with rules_wasm_component
   - Migration path from core Wasm
   - MoonBit-specific patterns and best practices

## Conclusion

This delegation approach provides the best of both worlds:
- **rules_wasm_component** becomes the expert in Component Model tooling
- **rules_moonbit** remains focused on MoonBit language expertise
- **Users** get a seamless, integrated experience

By working together, both rulesets can provide excellent Component Model support while maintaining clear responsibilities and avoiding duplication. This approach positions both rules_moonbit and rules_wasm_component as leaders in their respective domains while providing users with a cohesive, powerful WebAssembly development experience.

**Next Steps:**
1. ✅ Create this delegation strategy document (DONE)
2. [ ] Open issue in rules_wasm_component for MoonBit support
3. [ ] Implement rules_moonbit integration layer
4. [ ] Create joint documentation and examples
5. [ ] Develop comprehensive test suite
6. [ ] Gather community feedback and iterate