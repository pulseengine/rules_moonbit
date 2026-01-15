"""MoonBit compilation logic with real compiler integration - PRIVATE"""

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
load("//moonbit/private:optimization_utils.bzl", "generate_optimization_config")
load("//moonbit/private:diagnostics.bzl", "create_compilation_diagnostics")

def find_moon_executable(ctx):
    """Find MoonBit executable using multiple discovery strategies.
    
    Strategies in order:
    1. Registered Bazel toolchain (hermetic)
    2. System PATH
    3. Common installation locations
    4. Environment variables
    """
    # Strategy 1: Try registered Bazel toolchain (hermetic - preferred)
    if "//moonbit:moonbit_toolchain_type" in ctx.toolchains:
        toolchain = ctx.toolchains["//moonbit:moonbit_toolchain_type"]
        if toolchain and toolchain.moon_executable:
            ctx.actions.write(
                output = ctx.actions.declare_file("moon_executable_source.txt"),
                content = "Using MoonBit from registered hermetic toolchain: {}".format(toolchain.moon_executable.path),
                is_executable = False
            )
            return toolchain.moon_executable
    
    # Strategy 2: Try system PATH
    try:
        moon_path = ctx.which("moon")
        if moon_path:
            ctx.actions.write(
                output = ctx.actions.declare_file("moon_executable_source.txt"),
                content = "Using MoonBit from system PATH: {}".format(moon_path.path),
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
        "/usr/bin/moon",
        "C:/Program Files/MoonBit/bin/moon.exe",
        "C:/Program Files (x86)/MoonBit/bin/moon.exe"
    ]
    
    for location in common_locations:
        try:
            expanded_path = ctx.path(location)
            if expanded_path.exists:
                ctx.actions.write(
                    output = ctx.actions.declare_file("moon_executable_source.txt"),
                    content = "Using MoonBit from common location: {}".format(expanded_path.path),
                    is_executable = False
                )
                return expanded_path
        except:
            continue
    
    # Strategy 4: Try environment variables
    try:
        # Check MOONBIT_HOME environment variable
        moonbit_home = ctx.getenv("MOONBIT_HOME")
        if moonbit_home:
            moon_executable = ctx.path("{}/bin/moon".format(moonbit_home))
            if moon_executable.exists:
                ctx.actions.write(
                    output = ctx.actions.declare_file("moon_executable_source.txt"),
                    content = "Using MoonBit from MOONBIT_HOME: {}".format(moon_executable.path),
                    is_executable = False
                )
                return moon_executable
    except:
        pass
    
    # If no MoonBit found, create helpful error with setup instructions
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

Option 3: Set MOONBIT_HOME environment variable
- Set MOONBIT_HOME to your MoonBit installation directory
- Ensure $MOONBIT_HOME/bin/moon exists

Option 4: Specify custom toolchain location
Add to your MODULE.bazel:

moonbit_toolchain(
    name = "custom_moonbit",
    moon_executable = "//path/to:moon"
)

register_toolchains("@custom_moonbit//:moonbit_toolchain")
""",
        is_executable = False
    )
    
    # Create a placeholder executable that shows the error
    moon_placeholder = ctx.actions.declare_file("moon")
    ctx.actions.write(
        output = moon_placeholder,
        content = """#!/bin/bash
echo 'ERROR: MoonBit compiler not found.'
echo 'Please configure the hermetic toolchain or install MoonBit manually.'
echo 'See moon_setup_instructions.txt for detailed setup instructions.'
exit 1
""",
        is_executable = True
    )
    
    return moon_placeholder

def create_compilation_action(ctx, output_file, srcs, target="wasm", incremental=True, optimization="release", caching=True, cache_strategy="content_addressable"):
    """Create MoonBit compilation action with real compiler.
    
    Args:
        ctx: Rule context
        output_file: Output file to generate
        srcs: Source files to compile
        target: Target platform or "wasm", "js", "c", etc.
        incremental: Enable incremental compilation
        optimization: Optimization level (debug, release, aggressive)
        caching: Enable compilation caching
        cache_strategy: Cache strategy (content_addressable, timestamp, none)
    """
    moon_executable = find_moon_executable(ctx)
    
    if not moon_executable:
        # When MoonBit not available, fail with helpful error message
        fail("MoonBit compiler not found. Please configure the hermetic toolchain using moonbit_register_hermetic_toolchain() in your MODULE.bazel file.")
    
    # Build command line arguments for MoonBit compiler
    # Use the proper MoonBit command structure: moon build [options] [sources]
    args = [moon_executable.path, "build"]
    
    # Add target-specific arguments
    # Handle both simple targets (wasm, js, c) and cross-compilation platforms
    if target in ["wasm", "js", "c"]:
        args = args + ["--target", target]
    elif target:
        # Cross-compilation platform target
        args = args + ["--target", target]
        # Add platform-specific flags for cross-compilation
        if "linux" in target:
            args = args + ["--platform", "linux"]
        elif "windows" in target:
            args = args + ["--platform", "windows"]
        elif "darwin" in target:
            args = args + ["--platform", "darwin"]
    
    # Add incremental compilation flags
    if incremental:
        args = args + ["--incremental", "--cache"]
    
    # Add optimization flags
    if optimization == "debug":
        args = args + ["--debug", "--no-optimize"]
    elif optimization == "release":
        args = args + ["--optimize", "--release"]
    elif optimization == "aggressive":
        args = args + ["--optimize", "--aggressive", "--lto"]
    
    # Add caching flags
    if caching:
        args = args + ["--cache", "--cache-strategy", cache_strategy]
        # Add cache directory if needed
        if cache_strategy == "content_addressable":
            args = args + ["--cache-dir", ".moonbit/cache"]
    
    # Add output specification
    args = args + ["--output", output_file.path]
    
    # Add source files
    for src in srcs:
        args.append(src.path)
    
    # Create the compilation action
    ctx.actions.run(
        mnemonic = "MoonbitCompile",
        executable = moon_executable,
        arguments = args,
        inputs = srcs,
        outputs = [output_file],
        progress_message = "Compiling MoonBit: %s" % ctx.label.name
    )
    
    # Create compilation diagnostics
    compilation_result = {
        "compiled_objects": [output_file],
        "metadata": parse_metadata(ctx, output_file)
    }
    
    # Generate diagnostics for this compilation
    moonbit_info = MoonbitInfo(
        compiled_objects = [output_file],
        transitive_deps = [srcs],
        package_name = ctx.label.name,
        is_main = False,
        metadata = compilation_result["metadata"],
        target = target
    )
    
    create_compilation_diagnostics(ctx, moonbit_info, compilation_result)
    
    return output_file

def parse_metadata(ctx, output_file):
    """Parse MoonBit compilation metadata."""
    # In a real implementation, this would parse output from MoonBit compiler
    # For now, return basic metadata with cross-compilation support
    
    # Get target platform if specified
    target_platform = ""
    if hasattr(ctx.attr, 'target_platform') and ctx.attr.target_platform:
        target_platform = ctx.attr.target_platform
    
    metadata = {
        "package_name": ctx.label.name,
        "warnings": [],
        "dependencies": [],
        "platform": target_platform or "native",
        "moonbit_version": "latest"
    }
    
    # Add cross-compilation information if target platform is specified
    if target_platform:
        metadata["cross_compilation"] = {
            "target_platform": target_platform,
            "host_platform": str(ctx.platform),
            "is_cross_compilation": target_platform != str(ctx.platform)
        }
    
    # Add incremental compilation information
    if hasattr(ctx.attr, 'incremental'):
        metadata["incremental_compilation"] = {
            "enabled": ctx.attr.incremental,
            "strategy": "content_addressable" if ctx.attr.incremental else "none"
        }
    
    # Add optimization information
    if hasattr(ctx.attr, 'optimization'):
        metadata["optimization"] = {
            "level": ctx.attr.optimization,
            "settings": generate_optimization_config(ctx, target_platform or "native", ctx.attr.optimization)
        }
    
    # Add caching information
    if hasattr(ctx.attr, 'caching'):
        metadata["caching"] = {
            "enabled": ctx.attr.caching,
            "strategy": ctx.attr.cache_strategy,
            "performance_impact": "high" if ctx.attr.caching else "none"
        }
    
    return metadata

def create_test_action(ctx, srcs):
    """Create MoonBit test execution action."""
    moon_executable = find_moon_executable(ctx)
    
    if not moon_executable:
        # When MoonBit not available, fail with helpful error message
        fail("MoonBit compiler not found. Please configure the hermetic toolchain using moonbit_register_hermetic_toolchain() in your MODULE.bazel file.")
    
    # Build test command
    args = [moon_executable.path, "test"]
    
    # Add source files
    for src in srcs:
        args.append(src.path)
    
    # Create test action
    ctx.actions.run(
        mnemonic = "MoonbitTest",
        executable = moon_executable,
        arguments = args,
        inputs = srcs,
        outputs = [],
        progress_message = "Testing MoonBit: %s" % ctx.label.name
    )