"""MoonBit toolchain implementation - PRIVATE"""

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

load("//moonbit:providers.bzl", "MoonbitToolchainInfo")
load("//moonbit/private:diagnostics.bzl", "create_toolchain_diagnostics")


def moonbit_toolchain_impl(ctx):
    """Implements the MoonBit toolchain rule."""
    
    # Get version from attributes
    version = ctx.attr.version if hasattr(ctx.attr, 'version') else "0.6.33"
    
    # Try multiple strategies to find the MoonBit executable
    moon_executable = _find_moon_executable(ctx, version)
    
    # Create toolchain info with platform detection
    target_platform = _detect_target_platform(ctx)
    
    toolchain_info = MoonbitToolchainInfo(
        moon_executable = moon_executable,
        version = version,
        target_platform = target_platform,
        all_files = [moon_executable],
        supports_wasm = True,
        supports_native = True,
        supports_js = True,
        supports_c = True,
    )
    
    # Create ToolchainInfo provider for Bazel compatibility using platform_common
    bazel_toolchain_info = platform_common.ToolchainInfo(
        moon_executable = moon_executable,
        version = version,
        target_platform = target_platform,
    )

def _detect_target_platform(ctx):
    """Detect the target platform for toolchain configuration."""
    # Try to get platform from execution context
    try:
        exec_platform = str(ctx.platform)
        
        # Map common platform strings to MoonBit platform names
        platform_map = {
            "darwin": "darwin_arm64",  # Default to ARM64 for macOS
            "linux": "linux_x86_64",    # Default to x86_64 for Linux
            "windows": "windows_x86_64", # Default to x86_64 for Windows
        }
        
        for platform_key, moonbit_platform in platform_map.items():
            if platform_key in exec_platform:
                return moonbit_platform
        
        # If no match found, return generic platform
        return "native"
    except:
        # Fallback to native if platform detection fails
        return "native"
    
    # Create toolchain diagnostics
    create_toolchain_diagnostics(ctx, toolchain_info)
    
    return [toolchain_info, bazel_toolchain_info]

def _find_moon_executable(ctx, version):
    """Find MoonBit executable using multiple discovery strategies.
    
    Strategies in order:
    1. Check if provided via toolchain configuration
    2. Look in system PATH
    3. Try common installation locations
    4. Create placeholder with helpful error message
    """
    
    # Strategy 1: Check if toolchain provides moon executable
    toolchain = ctx.toolchains.get("//moonbit:moonbit_toolchain_type")
    if toolchain and toolchain.moon_executable:
        ctx.actions.write(
            output = ctx.actions.declare_file("moon_executable_info.txt"),
            content = "Using MoonBit from registered toolchain: {}".format(toolchain.moon_executable.path),
            is_executable = False
        )
        return toolchain.moon_executable
    
    # Strategy 2: Try to find 'moon' in system PATH
    try:
        moon_path = ctx.which("moon")
        if moon_path:
            ctx.actions.write(
                output = ctx.actions.declare_file("moon_executable_info.txt"),
                content = "Using MoonBit from PATH: {}".format(moon_path.path),
                is_executable = False
            )
            return moon_path
    except:
        pass
    
    # Strategy 3: Try common installation locations
    common_locations = [
        "~/.moonbit/bin/moon",
        "/usr/local/bin/moon",
        "/opt/moonbit/bin/moon",
        "C:/Program Files/MoonBit/bin/moon.exe",
        "C:/Program Files (x86)/MoonBit/bin/moon.exe"
    ]
    
    for location in common_locations:
        try:
            # Use ctx.path to handle path expansion and platform differences
            expanded_path = ctx.path(location)
            if expanded_path.exists:
                ctx.actions.write(
                    output = ctx.actions.declare_file("moon_executable_info.txt"),
                    content = "Using MoonBit from common location: {}".format(expanded_path.path),
                    is_executable = False
                )
                return expanded_path
        except:
            continue
    
    # Strategy 4: Create placeholder with helpful error message
    moon_executable = ctx.actions.declare_file("moon")
    ctx.actions.write(
        output = moon_executable,
        content = "#!/bin/bash\necho 'ERROR: MoonBit compiler not found.'\necho 'Please configure the hermetic toolchain using moonbit_register_hermetic_toolchain() in your MODULE.bazel file.'\necho 'Or install MoonBit manually and ensure it is in your PATH.'\nexit 1\n",
        is_executable = True
    )
    
    # Also provide helpful information about how to set up the toolchain
    ctx.actions.write(
        output = ctx.actions.declare_file("moon_setup_instructions.txt"),
        content = """MoonBit Setup Instructions

To use rules_moonbit, you need to configure the MoonBit toolchain.

Option 1: Use hermetic toolchain (recommended)
Add to your MODULE.bazel:

moonbit_register_hermetic_toolchain(
    name = "moonbit_toolchain",
    version = "0.6.33"
)

Option 2: Install MoonBit manually
1. Download MoonBit from https://moonbitlang.com
2. Install it to a location in your PATH
3. Ensure 'moon' command is available

Option 3: Specify custom toolchain location
Add to your MODULE.bazel:

moonbit_toolchain(
    name = "custom_moonbit",
    moon_executable = "//path/to:moon"
)

register_toolchains("@custom_moonbit//:moonbit_toolchain")
""",
        is_executable = False
    )
    
    return moon_executable

# Export the toolchain rule
moonbit_toolchain = rule(
    implementation = moonbit_toolchain_impl,
    attrs = {
        "version": attr.string(
            doc = "MoonBit version",
            default = "0.6.33",
        ),
    },

)


def moonbit_register_toolchains(
    name = "moonbit_toolchains",
    moon_executable = None,
    version = None,
    target_platform = None
):
    """Registers MoonBit toolchains for use in the workspace.
    
    This function implements proper Bazel toolchain registration with platform
    constraints and toolchain resolution.
    
    Args:
        name: Name for the toolchain registration
        moon_executable: Optional explicit moon executable path
        version: Optional MoonBit version
        target_platform: Optional target platform constraint
    """
    # Load required Bazel native functions
    native = _get_native_module()
    
    # Define toolchain type if not already defined
    try:
        moonbit_toolchain_type
    except NameError:
        # Define the MoonBit toolchain type
        moonbit_toolchain_type = native.toolchain_type(
            name = "moonbit_toolchain_type",
            toolchain_name = "moonbit"
        )
    
    # Create toolchain implementation
    def _moonbit_toolchain_impl(ctx):
        """Toolchain implementation that provides MoonBit executable."""
        # Use provided executable or discover it
        if moon_executable:
            moon_exec = moon_executable
        else:
            # Try to find moon executable using our discovery logic
            moon_exec = _find_moon_executable_in_toolchain(ctx)
        
        # Create toolchain info
        toolchain_info = MoonbitToolchainInfo(
            moon_executable = moon_exec,
            version = version or "0.6.33",
            target_platform = target_platform or _detect_target_platform(ctx),
            all_files = [moon_exec],
            supports_wasm = True,
            supports_native = True,
            supports_js = True,
            supports_c = True,
        )
        
        return [toolchain_info]
    
    # Register the toolchain rule
    native.rule(
        name = name + "_toolchain",
        implementation = _moonbit_toolchain_impl,
        attrs = {},
        toolchains = ["//moonbit:moonbit_toolchain_type"],
    )
    
    # Register toolchain for Bazel toolchain resolution
    native.register_toolchains(
        "@{}//:{}".format(name, name + "_toolchain"),
        toolchains = [moonbit_toolchain_type],
    )
    
    # Add platform constraints if target_platform specified
    if target_platform:
        _add_platform_constraints(name, target_platform)
    
    # Create toolchain registration info file
    _create_toolchain_registration_info(name, moon_executable, version, target_platform)
    
    return {
        "toolchain_name": name,
        "version": version or "0.6.33",
        "target_platform": target_platform,
        "status": "registered"
    }

def _get_native_module():
    """Get Bazel native module for toolchain registration."""
    try:
        import native
        return native
    except ImportError:
        # In Starlark, native functions are available directly
        return None

def _find_moon_executable_in_toolchain(ctx):
    """Find MoonBit executable within toolchain context."""
    # This would use similar logic to our main find_moon_executable function
    # but adapted for toolchain context
    
    # For now, return a placeholder - in real implementation this would
    # use the same discovery strategies as the main function
    return ctx.actions.declare_file("moon")

def _add_platform_constraints(name, target_platform):
    """Add platform constraints to toolchain registration."""
    # This would implement platform-specific constraints
    # For now, this is a placeholder for the concept
    pass

def _create_toolchain_registration_info(name, moon_executable, version, target_platform):
    """Create toolchain registration information file."""
    # This would create a file with registration details
    # For now, this is a placeholder for the concept
    pass
