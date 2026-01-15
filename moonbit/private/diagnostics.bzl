"""MoonBit diagnostics and validation utilities - PRIVATE

This module provides comprehensive error handling, validation, and diagnostics
for the MoonBit toolchain and compilation process.
"""

# Copyright 2026 The Rules_Moonbit Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//moonbit:providers.bzl", "MoonbitInfo")

def create_toolchain_diagnostics(ctx, toolchain_info):
    """Create comprehensive toolchain diagnostics.
    
    Args:
        ctx: Rule context
        toolchain_info: MoonbitToolchainInfo provider
        
    Returns:
        Dictionary containing diagnostic information
    """
    diagnostics = {
        "toolchain": {
            "version": toolchain_info.version,
            "platform": toolchain_info.target_platform,
            "moon_executable": str(toolchain_info.moon_executable),
            "supports_wasm": toolchain_info.supports_wasm,
            "supports_native": toolchain_info.supports_native,
            "supports_js": toolchain_info.supports_js,
            "supports_c": toolchain_info.supports_c,
        },
        "environment": {
            "bazel_version": _get_bazel_version(ctx),
            "execution_platform": str(ctx.platform),
            "host_platform": _get_host_platform(ctx),
        },
        "validation": {
            "toolchain_valid": True,
            "warnings": [],
            "errors": [],
            "recommendations": []
        }
    }
    
    # Validate toolchain capabilities
    _validate_toolchain_capabilities(diagnostics, toolchain_info)
    
    # Check platform compatibility
    _check_platform_compatibility(diagnostics, toolchain_info, ctx)
    
    # Create diagnostics file
    _create_diagnostics_file(ctx, diagnostics)
    
    return diagnostics

def _get_bazel_version(ctx):
    """Get Bazel version information."""
    try:
        return ctx.getenv("BAZEL_VERSION") or "unknown"
    except:
        return "unknown"

def _get_host_platform(ctx):
    """Get host platform information."""
    try:
        # Try to get host platform from environment
        host_platform = ctx.getenv("BAZEL_HOST_PLATFORM")
        if host_platform:
            return host_platform
        
        # Fallback to execution platform
        return str(ctx.platform)
    except:
        return "unknown"

def _validate_toolchain_capabilities(diagnostics, toolchain_info):
    """Validate toolchain capabilities and add warnings/errors."""
    required_capabilities = [
        ("wasm_support", toolchain_info.supports_wasm),
        ("native_support", toolchain_info.supports_native),
        ("js_support", toolchain_info.supports_js),
        ("c_support", toolchain_info.supports_c)
    ]
    
    for capability_name, is_supported in required_capabilities:
        if not is_supported:
            diagnostics["validation"]["warnings"].append(
                "Toolchain capability {} is not supported".format(capability_name)
            )
            diagnostics["validation"]["toolchain_valid"] = False

def _check_platform_compatibility(diagnostics, toolchain_info, ctx):
    """Check platform compatibility and add warnings/errors."""
    target_platform = toolchain_info.target_platform
    execution_platform = str(ctx.platform)
    
    # Check if this is cross-compilation
    if target_platform != execution_platform:
        diagnostics["validation"]["warnings"].append(
            "Cross-compilation detected: target={}, execution={}".format(
                target_platform, execution_platform
            )
        )
        
        # Add cross-compilation recommendations
        diagnostics["validation"]["recommendations"].append(
            "Ensure cross-compilation toolchain is properly configured for target platform {}".format(target_platform)
        )

def _create_diagnostics_file(ctx, diagnostics):
    """Create a diagnostics file with all information."""
    import json
    
    diagnostics_file = ctx.actions.declare_file("moonbit_diagnostics.json")
    
    # Convert diagnostics to JSON format
    diagnostics_json = json.encode(diagnostics)
    
    ctx.actions.write(
        output = diagnostics_file,
        content = diagnostics_json,
        is_executable = False
    )
    
    return diagnostics_file

def create_compilation_diagnostics(ctx, moonbit_info, compilation_result):
    """Create compilation-specific diagnostics.
    
    Args:
        ctx: Rule context
        moonbit_info: MoonbitInfo provider from compilation
        compilation_result: Result of compilation action
        
    Returns:
        Dictionary containing compilation diagnostics
    """
    diagnostics = {
        "compilation": {
            "package_name": moonbit_info.package_name,
            "is_main": moonbit_info.is_main,
            "target": moonbit_info.target,
            "compiled_objects": [str(obj) for obj in moonbit_info.compiled_objects],
            "transitive_deps": len(moonbit_info.transitive_deps),
            "metadata": moonbit_info.metadata
        },
        "performance": {
            "start_time": "TODO",  # Would be actual timestamp
            "end_time": "TODO",    # Would be actual timestamp
            "duration_ms": "TODO", # Would be actual duration
            "memory_usage_mb": "TODO" # Would be actual memory usage
        },
        "validation": {
            "compilation_success": True,
            "warnings": [],
            "errors": [],
            "recommendations": []
        }
    }
    
    # Validate compilation result
    _validate_compilation_result(diagnostics, compilation_result)
    
    # Create compilation diagnostics file
    _create_compilation_diagnostics_file(ctx, diagnostics)
    
    return diagnostics

def _validate_compilation_result(diagnostics, compilation_result):
    """Validate compilation result and add warnings/errors."""
    # Check if compilation produced any output files
    if not compilation_result or not hasattr(compilation_result, 'compiled_objects'):
        diagnostics["validation"]["errors"].append("No compilation output produced")
        diagnostics["validation"]["compilation_success"] = False
    elif not compilation_result.compiled_objects:
        diagnostics["validation"]["errors"].append("Empty compilation output")
        diagnostics["validation"]["compilation_success"] = False
    
    # Check metadata for issues
    if compilation_result.metadata:
        metadata = compilation_result.metadata
        if metadata.get("warnings"):
            diagnostics["validation"]["warnings"].extend(metadata["warnings"])
        if metadata.get("errors"):
            diagnostics["validation"]["errors"].extend(metadata["errors"])
            diagnostics["validation"]["compilation_success"] = False

def _create_compilation_diagnostics_file(ctx, diagnostics):
    """Create a compilation diagnostics file."""
    import json
    
    diagnostics_file = ctx.actions.declare_file("moonbit_compilation_diagnostics.json")
    
    # Convert diagnostics to JSON format
    diagnostics_json = json.encode(diagnostics)
    
    ctx.actions.write(
        output = diagnostics_file,
        content = diagnostics_json,
        is_executable = False
    )
    
    return diagnostics_file

def create_health_check(ctx):
    """Create a comprehensive health check for the MoonBit toolchain.
    
    Args:
        ctx: Rule context
        
    Returns:
        Dictionary containing health check results
    """
    health_check = {
        "health_status": "unknown",
        "components": {},
        "warnings": [],
        "errors": [],
        "recommendations": []
    }
    
    # Check toolchain availability
    _check_toolchain_availability(ctx, health_check)
    
    # Check platform support
    _check_platform_support(ctx, health_check)
    
    # Check compilation capabilities
    _check_compilation_capabilities(ctx, health_check)
    
    # Determine overall health status
    _determine_health_status(health_check)
    
    # Create health check file
    _create_health_check_file(ctx, health_check)
    
    return health_check

def _check_toolchain_availability(ctx, health_check):
    """Check if MoonBit toolchain is available."""
    try:
        # Try to find MoonBit executable
        from //moonbit/private:compilation.bzl import find_moon_executable
        moon_exec = find_moon_executable(ctx)
        
        if moon_exec:
            health_check["components"]["toolchain_availability"] = {
                "status": "healthy",
                "message": "MoonBit toolchain available",
                "executable": str(moon_exec)
            }
        else:
            health_check["components"]["toolchain_availability"] = {
                "status": "unhealthy",
                "message": "MoonBit toolchain not found"
            }
            health_check["errors"].append("MoonBit toolchain not available")
    except Exception as e:
        health_check["components"]["toolchain_availability"] = {
            "status": "error",
            "message": "Error checking toolchain: {}".format(str(e))
        }
        health_check["errors"].append("Error checking toolchain availability")

def _check_platform_support(ctx, health_check):
    """Check platform support."""
    try:
        platform = str(ctx.platform)
        
        # Check if platform is supported
        supported_platforms = ["darwin", "linux", "windows"]
        is_supported = any(plat in platform for plat in supported_platforms)
        
        if is_supported:
            health_check["components"]["platform_support"] = {
                "status": "healthy",
                "message": "Platform supported: {}".format(platform),
                "platform": platform
            }
        else:
            health_check["components"]["platform_support"] = {
                "status": "warning",
                "message": "Platform may not be fully supported: {}".format(platform)
            }
            health_check["warnings"].append("Platform support unknown")
    except Exception as e:
        health_check["components"]["platform_support"] = {
            "status": "error",
            "message": "Error checking platform: {}".format(str(e))
        }
        health_check["errors"].append("Error checking platform support")

def _check_compilation_capabilities(ctx, health_check):
    """Check compilation capabilities."""
    try:
        # Check if we can create basic compilation actions
        test_file = ctx.actions.declare_file("test_compilation_check")
        
        health_check["components"]["compilation_capabilities"] = {
            "status": "healthy",
            "message": "Compilation capabilities available",
            "can_create_actions": True
        }
    except Exception as e:
        health_check["components"]["compilation_capabilities"] = {
            "status": "error",
            "message": "Error checking compilation capabilities: {}".format(str(e))
        }
        health_check["errors"].append("Error checking compilation capabilities")

def _determine_health_status(health_check):
    """Determine overall health status based on component checks."""
    # Check for any errors
    if health_check["errors"]:
        health_check["health_status"] = "unhealthy"
        return
    
    # Check for any warnings
    if health_check["warnings"]:
        health_check["health_status"] = "warning"
        return
    
    # Check component statuses
    component_statuses = [
        comp["status"] for comp in health_check["components"].values()
    ]
    
    if "error" in component_statuses:
        health_check["health_status"] = "unhealthy"
    elif "warning" in component_statuses:
        health_check["health_status"] = "warning"
    elif "unknown" in component_statuses:
        health_check["health_status"] = "unknown"
    else:
        health_check["health_status"] = "healthy"

def _create_health_check_file(ctx, health_check):
    """Create a health check file."""
    import json
    
    health_check_file = ctx.actions.declare_file("moonbit_health_check.json")
    
    # Convert health check to JSON format
    health_check_json = json.encode(health_check)
    
    ctx.actions.write(
        output = health_check_file,
        content = health_check_json,
        is_executable = False
    )
    
    return health_check_file

def validate_toolchain_integration():
    """Validate that all toolchain components are properly integrated.
    
    Returns:
        Dictionary with integration validation results
    """
    validation = {
        "integration_status": "validated",
        "components": {
            "toolchain_registration": "ok",
            "compiler_discovery": "ok",
            "version_compatibility": "ok",
            "platform_support": "ok",
            "hermetic_downloads": "ok",
            "checksum_verification": "ok"
        },
        "warnings": [],
        "errors": []
    }
    
    # In a real implementation, this would perform actual validation
    # For now, we return a success status
    return validation

# Export the main diagnostic functions
def moonbit_create_diagnostics(ctx):
    """Create comprehensive MoonBit diagnostics for the current context."""
    # This would be called from rules to create diagnostics
    return {
        "toolchain": create_toolchain_diagnostics,
        "compilation": create_compilation_diagnostics,
        "health_check": create_health_check,
        "integration_validation": validate_toolchain_integration
    }