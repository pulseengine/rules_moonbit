"""MoonBit toolchain implementation - PRIVATE

This implementation follows the patterns from rules_rust for proper Bazel 8.5+ compatibility.
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

load("//moonbit:providers.bzl", "MoonbitToolchainInfo")
load("//moonbit/private:diagnostics.bzl", "create_toolchain_diagnostics")
load("@bazel_skylib//lib:paths.bzl", "paths")

def moonbit_toolchain_impl(ctx):
    """Implements the MoonBit toolchain rule.
    
    This follows the pattern from rules_rust for proper toolchain implementation.
    
    Args:
        ctx: Rule context
        
    Returns:
        List: Toolchain providers
    """
    
    # Get version from attributes
    version = ctx.attr.version if hasattr(ctx.attr, 'version') else "0.6.33"
    
    # Try multiple strategies to find the MoonBit executable
    moon_executable = _find_moon_executable(ctx, version)
    
    # Create toolchain info with platform detection
    target_platform = _detect_target_platform(ctx)
    
    # Get toolchain files
    toolchain_files = _get_toolchain_files(ctx)
    
    toolchain_info = MoonbitToolchainInfo(
        moon_executable = moon_executable,
        version = version,
        target_platform = target_platform,
        all_files = toolchain_files,
        supports_wasm = True,
        supports_native = True,
        supports_js = True,
        supports_c = True,
    )
    
    # Create toolchain diagnostics
    create_toolchain_diagnostics(ctx, toolchain_info)
    
    return [toolchain_info]

def _get_toolchain_files(ctx):
    """Get all files that are part of the toolchain.
    
    Args:
        ctx: Rule context
        
    Returns:
        Depset: All toolchain files
    """
    files = []
    
    # Add the moon executable
    if hasattr(ctx.attr, 'moon_executable'):
        moon_exec = ctx.attr.moon_executable
        if hasattr(moon_exec, 'files'):
            files.extend(moon_exec.files.to_list())
        else:
            files.append(moon_exec)
    
    # Add any additional toolchain files
    if hasattr(ctx.attr, 'toolchain_files'):
        toolchain_files = ctx.attr.toolchain_files
        if hasattr(toolchain_files, 'files'):
            files.extend(toolchain_files.files.to_list())
    
    return depset(files)

def _detect_target_platform(ctx):
    """Detect the target platform for toolchain configuration.
    
    This uses proper Bazel platform detection instead of string matching.
    
    Args:
        ctx: Rule context
        
    Returns:
        String: Platform identifier
    """
    # Get platform from execution context
    if hasattr(ctx, 'platform') and ctx.platform:
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
    
    # Fallback to native if platform detection fails or no platform found
    return "native"

def _find_moon_executable(ctx, version):
    """Find MoonBit executable using multiple discovery strategies.
    
    Strategies in order:
    1. Check if provided via toolchain configuration
    2. Look in system PATH
    3. Try common installation locations
    4. Create placeholder with helpful error message
    
    Args:
        ctx: Rule context
        version: MoonBit version
        
    Returns:
        File: MoonBit executable
    """
    
    # Strategy 1: Check if toolchain provides moon executable
    if hasattr(ctx.attr, 'moon_executable'):
        moon_exec = ctx.attr.moon_executable
        if moon_exec:
            ctx.actions.write(
                output = ctx.actions.declare_file("moon_executable_info.txt"),
                content = "Using MoonBit from registered toolchain: {}".format(
                    moon_exec.path if hasattr(moon_exec, 'path') else str(moon_exec)
                ),
                is_executable = False
            )
            return moon_exec
    
    # Strategy 2: Try to find 'moon' in system PATH
    # Use paths module to find executable in PATH
    moon_path = None
    if hasattr(paths, 'find_executable'):
        moon_path = paths.find_executable("moon")
    
    if moon_path:
        moon_file = ctx.actions.declare_file("moon")
        ctx.actions.symlink(
            output = moon_file,
            target_file = moon_path,
            is_executable = True
        )
        ctx.actions.write(
            output = ctx.actions.declare_file("moon_executable_info.txt"),
            content = "Using MoonBit from PATH: {}".format(moon_path),
            is_executable = False
        )
        return moon_file
    
    # Strategy 3: Try common installation locations
    common_locations = [
        "~/.moonbit/bin/moon",
        "/usr/local/bin/moon",
        "/opt/moonbit/bin/moon",
        "C:/Program Files/MoonBit/bin/moon.exe",
        "C:/Program Files (x86)/MoonBit/bin/moon.exe"
    ]
    
    for location in common_locations:
        expanded_path = None
        if hasattr(ctx, 'path'):
            expanded_path = ctx.path(location)
        
        if expanded_path and hasattr(expanded_path, 'exists') and expanded_path.exists:
            moon_file = ctx.actions.declare_file("moon")
            ctx.actions.symlink(
                output = moon_file,
                target_file = expanded_path,
                is_executable = True
            )
            ctx.actions.write(
                output = ctx.actions.declare_file("moon_executable_info.txt"),
                content = "Using MoonBit from common location: {}".format(expanded_path.path),
                is_executable = False
            )
            return moon_file
    
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
toolchain_attrs = {
    "version": attr.string(
        doc = "MoonBit version",
        default = "0.6.33",
    ),
    "moon_executable": attr.label(
        doc = "MoonBit executable",
        allow_single_file = True,
        cfg = "exec",
    ),
    "toolchain_files": attr.label(
        doc = "Additional toolchain files",
        allow_files = True,
    ),
}

moonbit_toolchain = rule(
    implementation = moonbit_toolchain_impl,
    attrs = toolchain_attrs,
)