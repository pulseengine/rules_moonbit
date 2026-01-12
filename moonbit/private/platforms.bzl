"""Platform and target configuration for MoonBit multi-target compilation - PRIVATE"""

# Platform definitions for different compilation targets
PLATFORM_DEFINITIONS = {
    "wasm": {
        "name": "WebAssembly",
        "extension": ".wasm",
        "bazel_target": "wasm",
        "output_type": "binary",
        "consumer_rules": ["wasm_binary", "wasm_library"],
        "ffi_type": "wasm",
        "supports_ffi": True,
        "default_optimization": "size",
    },
    "js": {
        "name": "JavaScript",
        "extension": ".js",
        "bazel_target": "js",
        "output_type": "javascript",
        "consumer_rules": ["js_binary", "js_library", "js_test"],
        "ffi_type": "javascript",
        "supports_ffi": True,
        "default_optimization": "speed",
        "module_system": "esm",  # ES Modules
    },
    "c": {
        "name": "C",
        "extension": ".c",
        "bazel_target": "cc",
        "output_type": "c_source",
        "consumer_rules": ["cc_binary", "cc_library", "cc_test"],
        "ffi_type": "native",
        "supports_ffi": True,
        "default_optimization": "speed",
        "header_extension": ".h",
    },
    "native": {
        "name": "Native",
        "extension": "",  # Platform-specific executable
        "bazel_target": "cc",
        "output_type": "executable",
        "consumer_rules": ["cc_binary"],
        "ffi_type": "native",
        "supports_ffi": True,
        "default_optimization": "speed",
    }
}

def get_platform_config(target):
    """Get platform configuration for a given target."""
    return PLATFORM_DEFINITIONS.get(target, PLATFORM_DEFINITIONS["wasm"])

def get_bazel_consumer_rules(target):
    """Get Bazel rules that can consume this MoonBit target's output."""
    config = get_platform_config(target)
    return config["consumer_rules"]

def get_output_extension(target):
    """Get file extension for the given target."""
    return get_platform_config(target)["extension"]

def get_bazel_target_type(target):
    """Get the Bazel target type for integration."""
    return get_platform_config(target)["bazel_target"]

def get_ffi_type(target):
    """Get FFI type for the target."""
    return get_platform_config(target)["ffi_type"]

def generate_target_specific_json(ctx, target, output_file):
    """Generate target-specific JSON configuration."""
    platform_config = get_platform_config(target)
    
    target_json = {
        "target_specific": {
            "target_type": target,
            "platform_name": platform_config["name"],
            "output_extension": platform_config["extension"],
            "bazel_integration": {
                "target_type": platform_config["bazel_target"],
                "output_type": platform_config["output_type"],
                "consumer_rules": platform_config["consumer_rules"],
                "ffi_compatibility": platform_config["ffi_type"],
            },
            "compilation_options": {
                "optimization": platform_config["default_optimization"],
                "module_system": platform_config.get("module_system", "none"),
                "generate_headers": platform_config.get("header_extension", None) != None,
            },
            "interoperability": {
                "supports_ffi": platform_config["supports_ffi"],
                "ffi_type": platform_config["ffi_type"],
                "bazel_ffi_rules": get_ffi_integration_rules(target),
            }
        }
    }
    
    # Add target-specific settings
    if target == "js":
        target_json["target_specific"]["javascript"] = {
            "module_format": "esm",
            "browser_compatible": True,
            "node_compatible": True,
            "bazel_js_integration": {
                "can_consume_with": ["js_import", "js_library"],
                "generates_declarations": True,
            }
        }
    
    elif target == "c":
        target_json["target_specific"]["c"] = {
            "header_file": output_file.path.replace(platform_config["extension"], platform_config.get("header_extension", ".h")),
            "bazel_cc_integration": {
                "can_consume_with": ["cc_library", "cc_binary"],
                "generates_header": True,
                "header_dependencies": [],
            },
            "compilation_flags": ["-std=c11", "-Wall"],
        }
    
    elif target == "wasm":
        target_json["target_specific"]["wasm"] = {
            "wasm_features": ["bulk-memory", "reference-types", "gc"],
            "bazel_wasm_integration": {
                "can_consume_with": ["wasm_binary", "wasm_library"],
                "wasm_toolchain_compatible": True,
            },
            "export_functions": [],
            "import_functions": [],
        }
    
    return target_json

def get_ffi_integration_rules(target):
    """Get Bazel rules for FFI integration with the target."""
    ffi_rules = {
        "wasm": ["wasm_ffi", "js_ffi"],
        "js": ["js_ffi", "nodejs_ffi"],
        "c": ["cc_ffi", "native_ffi"],
        "native": ["cc_ffi", "native_ffi"],
    }
    return ffi_rules.get(target, [])

def generate_bazel_integration_config(target, moonbit_output, ctx):
    """Generate Bazel integration configuration for the target output."""
    platform_config = get_platform_config(target)
    
    integration_config = {
        "bazel_integration": {
            "moonbit_target": str(ctx.label),
            "output_file": moonbit_output.path,
            "output_type": platform_config["output_type"],
            "target_platform": target,
            "consumer_rules": platform_config["consumer_rules"],
            "integration_method": get_integration_method(target),
            "dependency_info": {
                "moonbit_deps": [str(dep.label) for dep in ctx.attr.deps if hasattr(dep, 'label')],
                "generated_files": [moonbit_output.path],
            }
        }
    }
    
    # Add target-specific integration details
    if target == "js":
        integration_config["bazel_integration"]["javascript"] = {
            "js_module_name": ctx.label.name,
            "js_import_path": "//" + ctx.label.package + ":" + ctx.label.name,
            "can_be_imported_by": ["js_library", "js_binary", "js_test"],
            "generates": {
                "source_file": moonbit_output.path,
                "declaration_file": moonbit_output.path.replace(".js", ".d.ts"),
            }
        }
    
    elif target == "c":
        header_file = moonbit_output.path.replace(".c", ".h")
        integration_config["bazel_integration"]["c"] = {
            "header_file": header_file,
            "source_file": moonbit_output.path,
            "can_be_imported_by": ["cc_library", "cc_binary", "cc_test"],
            "compilation": {
                "includes": [ctx.label.package],
                "defines": ["MOONBIT_GENERATED"],
            }
        }
    
    elif target == "wasm":
        integration_config["bazel_integration"]["wasm"] = {
            "wasm_module": ctx.label.name,
            "can_be_imported_by": ["wasm_library", "wasm_binary"],
            "wasm_features": {
                "uses_gc": True,
                "uses_reference_types": True,
            }
        }
    
    return integration_config

def get_integration_method(target):
    """Get the integration method for the target."""
    methods = {
        "wasm": "wasm_module",
        "js": "js_module",
        "c": "cc_library",
        "native": "cc_binary",
    }
    return methods.get(target, "unknown")

def get_target_from_label(ctx):
    """Determine target from context or use default."""
    # Check if target is specified in attributes
    if hasattr(ctx.attr, 'target') and ctx.attr.target:
        return ctx.attr.target
    
    # Check environment or platform
    platform = str(ctx.platform)
    if "windows" in platform.lower():
        return "native"  # Windows native
    elif "linux" in platform.lower() or "darwin" in platform.lower():
        return "wasm"  # Unix-like default to Wasm
    
    # Default to Wasm
    return "wasm"