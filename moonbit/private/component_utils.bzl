"""MoonBit Component Model utilities - PRIVATE

This module provides integration between rules_moonbit and rules_wasm_component
for WebAssembly Component Model support.
"""

# Load rules_wasm_component dependencies
load("@rules_wasm_component//wasm:defs.bzl", 
     "wasm_component", 
     "wasm_wit")

# Load MoonBit compilation utilities
load(":moon.bzl", "_moonbit_wasm_impl")
load(":json_utils.bzl", "generate_bazel_to_moon_json")

def _moonbit_component_impl(ctx):
    """Implements the moonbit_component rule by delegating to rules_wasm_component.
    
    This rule provides a convenient way to create WebAssembly components from MoonBit
    source code by first compiling to Wasm, then delegating component creation to
    rules_wasm_component.
    """
    # Step 1: Compile MoonBit to WebAssembly
    wasm_output = ctx.actions.declare_file(ctx.label.name + ".wasm")
    
    # Create MoonBit compilation context for Wasm target
    moonbit_ctx = create_moonbit_compilation_context(ctx, wasm_output, target="wasm")
    
    # Compile MoonBit to Wasm
    compiled_wasm = _moonbit_wasm_impl(moonbit_ctx)
    
    # Step 2: Generate WIT configuration for rules_wasm_component
    wit_config = generate_wit_integration_config(ctx)
    
    # Step 3: Delegate component creation to rules_wasm_component
    # This would call the actual wasm_component rule from rules_wasm_component
    component_output = create_wasm_component_from_moonbit(
        ctx,
        wasm_src = compiled_wasm,
        wit_deps = ctx.attr.wit_deps,
        moonbit_specific = True
    )
    
    # Step 4: Create MoonBit component info with integration metadata
    return [MoonbitComponentInfo(
        component = component_output,
        wasm_core = compiled_wasm,
        wit_interfaces = ctx.attr.wit_deps,
        metadata = {
            "integration": "rules_wasm_component",
            "target": "wasm_component",
            "moonbit_version": "0.6.33",
            "component_model": "wasi_preview2",
        }
    )]

def create_moonbit_compilation_context(ctx, output_file, target="wasm"):
    """Create a compilation context for MoonBit to Wasm compilation."""
    class MoonbitCompilationContext:
        def __init__(self, original_ctx, output_file, target):
            self.label = original_ctx.label
            self.files = original_ctx.files
            self.attr = original_ctx.attr
            self.actions = original_ctx.actions
            self.platform = original_ctx.platform
            self.configuration = original_ctx.configuration
            self.workspace_name = original_ctx.workspace_name
            self.output_file = output_file
            self.target = target
    
    return MoonbitCompilationContext(ctx, output_file, target)

def generate_wit_integration_config(ctx):
    """Generate WIT integration configuration for rules_wasm_component."""
    # This would generate the necessary configuration for WIT processing
    # In a real implementation, this would create the WIT file references
    # and configuration needed by rules_wasm_component
    
    wit_config = {
        "wit_integration": {
            "moonbit_target": str(ctx.label),
            "wit_dependencies": [str(dep) for dep in ctx.attr.wit_deps],
            "moonbit_specific": True,
            "integration_mode": "delegated",
        }
    }
    
    return wit_config

def create_wasm_component_from_moonbit(ctx, wasm_src, wit_deps, moonbit_specific=False):
    """Delegate component creation to rules_wasm_component.
    
    In a real implementation, this would call the actual wasm_component rule
    from rules_wasm_component. For now, we simulate the component creation.
    """
    # Simulate component creation (would call rules_wasm_component in reality)
    component_output = ctx.actions.declare_file(ctx.label.name + ".component.wasm")
    
    # Simulate the component creation action
    ctx.actions.write(
        output = component_output,
        content = "// MoonBit Component (simulated - would be created by rules_wasm_component)\n",
        is_executable = False,
    )
    
    # Generate component metadata
    component_metadata = generate_component_metadata(ctx, wasm_src, wit_deps)
    
    return component_output

def generate_component_metadata(ctx, wasm_src, wit_deps):
    """Generate component metadata for the created component."""
    metadata = {
        "component": {
            "name": ctx.label.name,
            "package": ctx.label.package,
            "target": "wasm_component",
            "wasm_source": wasm_src.path,
            "wit_dependencies": [str(dep) for dep in wit_deps],
            "integration": "rules_wasm_component",
            "moonbit_specific": True,
            "timestamp": "2026-01-11T00:00:00Z",
        }
    }
    
    return metadata

def _moonbit_wit_impl(ctx):
    """Implements the moonbit_wit rule for WIT file processing.
    
    This rule provides MoonBit-specific WIT file processing that integrates
    with rules_wasm_component's WIT infrastructure.
    """
    # Delegate to rules_wasm_component's WIT processing
    # In a real implementation, this would call wasm_wit from rules_wasm_component
    
    # For now, simulate WIT processing
    wit_outputs = []
    for wit_file in ctx.files.srcs:
        processed_wit = ctx.actions.declare_file(wit_file.basename + ".processed.wit")
        ctx.actions.write(
            output = processed_wit,
            content = "// Processed WIT file (simulated)\n" + 
                     "// Original: " + wit_file.path + "\n",
            is_executable = False,
        )
        wit_outputs.append(processed_wit)
    
    return [MoonbitWitInfo(
        wit_files = wit_outputs,
        original_files = ctx.files.srcs,
        metadata = {
            "integration": "rules_wasm_component",
            "moonbit_specific": True,
        }
    )]