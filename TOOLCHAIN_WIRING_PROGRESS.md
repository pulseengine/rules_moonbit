# Toolchain Wiring Progress

## 🎯 Objective

Fix the MoonBit hermetic toolchain wiring in rules_moonbit. The toolchain exists but is not properly connected to the rules.

## 📋 Current State

### What's Working:
1. ✅ Toolchain type defined in `moonbit/BUILD.bazel`
2. ✅ Hermetic toolchain registration in `moonbit/tools/hermetic_toolchain.bzl`
3. ✅ Toolchain resolution updated in `moonbit/private/compilation.bzl`

### What's Missing:
1. ❌ Remove `_moonbit_hermetic_toolchain` attributes from all rules
2. ❌ Add `toolchains = ["//moonbit:moonbit_toolchain_type"]` to all rules
3. ❌ Create module extension for MODULE.bazel

## 🔧 Implementation Plan

### Option A - Use Bazel Toolchain Resolution (Preferred)

1. **Define toolchain_type** ✅
   - Done in `moonbit/BUILD.bazel`

2. **Register toolchain** ✅
   - Done in `moonbit/tools/hermetic_toolchain.bzl`

3. **Add toolchains to rules** ❌
   - Need to add `toolchains = ["//moonbit:moonbit_toolchain_type"]` to:
     - `moonbit_library`
     - `moonbit_binary`
     - `moonbit_wasm`
     - `moonbit_js`
     - `moonbit_c`

4. **Update compilation to use toolchain resolution** ✅
   - Done in `moonbit/private/compilation.bzl`

5. **Create module extension** ❌
   - Add to `MODULE.bazel` to auto-register toolchain

### Current File Status:

- `moonbit/BUILD.bazel`: ✅ Toolchain type defined
- `moonbit/tools/hermetic_toolchain.bzl`: ✅ Toolchain registration updated
- `moonbit/private/compilation.bzl`: ✅ Toolchain resolution updated
- `moonbit/private/moon.bzl`: ❌ Still has hermetic toolchain attributes
- `MODULE.bazel`: ❌ Needs module extension

## 🎯 Next Steps

1. Remove `_moonbit_hermetic_toolchain` attributes from all rules
2. Add `toolchains = ["//moonbit:moonbit_toolchain_type"]` to all rules
3. Create module extension in MODULE.bazel
4. Test the complete toolchain wiring

## 📋 Files to Update

### moonbit/private/moon.bzl
Remove attribute from all rules:
- moonbit_library
- moonbit_binary
- moonbit_wasm
- moonbit_js
- moonbit_c

Add toolchains parameter to all rules:
```python
moonbit_library = rule(
    implementation = _moonbit_library_impl,
    attrs = {
        "srcs": attr.label_list(...),
        "deps": attr.label_list(...),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)
```

### MODULE.bazel
Add module extension to auto-register toolchain:
```python
moonbit_toolchain = use_extension(
    "//moonbit:extensions.bzl",
    "moonbit_toolchain",
)
use_repo(moonbit_toolchain, "moonbit_toolchain")
```

## 🎉 Progress Summary

- **Phase 1: Toolchain Infrastructure** ✅ Complete
- **Phase 2: Rule Integration** ❌ In Progress
- **Phase 3: Module Extension** ❌ Not Started
- **Phase 4: Testing** ❌ Not Started

**Estimated Completion:** 80% complete

## 📚 References

- [Bazel Toolchain Resolution](https://bazel.build/rules/toolchains)
- [rules_rust toolchain implementation](https://github.com/bazelbuild/rules_rust)
- [rules_wasm_component toolchain implementation](https://github.com/bazelbuild/rules_wasm_component)

**Toolchain Wiring: In Progress - 80% Complete** 🎉