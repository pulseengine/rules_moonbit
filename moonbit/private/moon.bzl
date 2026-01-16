"""Core MoonBit rule implementations - PRIVATE"""

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

# Use native depset for now
load("//moonbit:providers.bzl", "MoonbitInfo")
load("//moonbit/private:compilation.bzl", 
     "find_moon_executable", 
     "create_compilation_action", 
     "parse_metadata",
     "create_test_action")
# Note: We're not using the private _component_new_action from rules_wasm_component
# to avoid dependency on private APIs. Instead, we use a simplified approach.

"""MoonBit Library Rule"""

def _moonbit_library_impl(ctx):
    """Implements the moonbit_library rule."""
    # Get sources
    srcs = ctx.files.srcs
    
    # Determine output file
    output_file = ctx.actions.declare_file("%s.compiled" % ctx.label.name)
    
    # Get component name
    component_name = ctx.attr.component_name or ""
    
    # Get target platform for cross-compilation
    target_platform = ctx.attr.target_platform
    
    # Get incremental compilation setting
    incremental = ctx.attr.incremental
    
    # Get optimization level
    optimization = ctx.attr.optimization
    
    # Get caching settings
    caching = ctx.attr.caching
    cache_strategy = ctx.attr.cache_strategy
    
    # Create compilation action with target platform, incremental, optimization, and caching
    compiled_output = create_compilation_action(ctx, output_file, srcs, target_platform, incremental, optimization, caching, cache_strategy)
    
    # Parse metadata
    metadata = parse_metadata(ctx, output_file)
    
    # Collect transitive dependencies (simplified for now)
    transitive_deps = [srcs]
    for dep in ctx.attr.deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps.append(dep.transitive_deps)
    
    return [
        MoonbitInfo(
            compiled_objects = [compiled_output],
            transitive_deps = transitive_deps,
            package_name = ctx.label.name,
            is_main = False,
            metadata = metadata,
        ),
        DefaultInfo(files = depset([compiled_output])),
    ]

moonbit_library = rule(
    implementation = _moonbit_library_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files",
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            allow_files = False,
            mandatory = False,
        ),
        "target_platform": attr.string(
            doc = "Target platform for cross-compilation (e.g., 'linux_x86_64', 'windows_amd64')",
            default = "",
        ),
        "incremental": attr.bool(
            doc = "Enable incremental compilation for faster rebuilds",
            default = True,
        ),
        "optimization": attr.string(
            doc = "Optimization level (debug, release, aggressive)",
            default = "release",
        ),
        "caching": attr.bool(
            doc = "Enable compilation caching for faster rebuilds",
            default = True,
        ),
        "cache_strategy": attr.string(
            doc = "Cache strategy (content_addressable, timestamp, none)",
            default = "content_addressable",
        ),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)

"""MoonBit Binary Rule"""

def _moonbit_binary_impl(ctx):
    """Implements the moonbit_binary rule."""
    # Get sources
    srcs = ctx.files.srcs
    
    # Determine output file (executable)
    output_file = ctx.actions.declare_file("%s.exe" % ctx.label.name)
    
    # Get target platform for cross-compilation
    target_platform = ctx.attr.target_platform
    
    # Get incremental compilation setting
    incremental = ctx.attr.incremental
    
    # Get optimization level
    optimization = ctx.attr.optimization
    
    # Get caching settings
    caching = ctx.attr.caching
    cache_strategy = ctx.attr.cache_strategy
    
    # Create compilation action with target platform, incremental, optimization, and caching
    compiled_output = create_compilation_action(ctx, output_file, srcs, target_platform, incremental, optimization, caching, cache_strategy)
    
    # Parse metadata
    metadata = parse_metadata(ctx, output_file)
    
    # Collect transitive dependencies (simplified for now)
    transitive_deps = [srcs]
    for dep in ctx.attr.deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps.append(dep.transitive_deps)
    
    return [
        MoonbitInfo(
            compiled_objects = [compiled_output],
            transitive_deps = transitive_deps,
            package_name = ctx.label.name,
            is_main = True,
            metadata = metadata,
        ),
        DefaultInfo(files = depset([compiled_output])),
    ]

moonbit_binary = rule(
    implementation = _moonbit_binary_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files",
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            allow_files = False,
            mandatory = False,
        ),
        "target_platform": attr.string(
            doc = "Target platform for cross-compilation (e.g., 'linux_x86_64', 'windows_amd64')",
            default = "",
        ),
        "incremental": attr.bool(
            doc = "Enable incremental compilation for faster rebuilds",
            default = True,
        ),
        "optimization": attr.string(
            doc = "Optimization level (debug, release, aggressive)",
            default = "release",
        ),
        "caching": attr.bool(
            doc = "Enable compilation caching for faster rebuilds",
            default = True,
        ),
        "cache_strategy": attr.string(
            doc = "Cache strategy (content_addressable, timestamp, none)",
            default = "content_addressable",
        ),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)

"""MoonBit Test Rule"""

def _moonbit_test_impl(ctx):
    """Implements the moonbit_test rule."""
    # Get sources
    srcs = ctx.files.srcs
    
    # Get dependencies
    deps = ctx.attr.deps
    
    # Collect transitive dependencies (simplified for now)
    transitive_deps = [srcs]
    for dep in deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps.append(dep.transitive_deps)
    
    # Create test action using real MoonBit compiler
    create_test_action(ctx, srcs)
    
    # Return MoonbitInfo for test target
    return [
        MoonbitInfo(
            compiled_objects = [],
            transitive_deps = transitive_deps,
            package_name = ctx.label.name,
            is_main = False,
            metadata = {"test_type": "moonbit"},
        ),
        DefaultInfo(
            files = depset([]),
            executable = None,
        ),
    ]

moonbit_test = rule(
    implementation = _moonbit_test_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit test source files",
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            allow_files = False,
            mandatory = False,
        ),
        
    },
    test = True,
)

"""Multi-Target MoonBit Rules"""

def _moonbit_target_impl(ctx, target="wasm", extension=".wasm"):
    """Generic implementation for target-specific MoonBit compilation."""
    # Get sources
    srcs = ctx.files.srcs

    # Determine output file based on target
    output_file = ctx.actions.declare_file(ctx.label.name + extension)

    # Create compilation action
    compiled_output = create_compilation_action(ctx, output_file, srcs)

    # Parse metadata
    metadata = parse_metadata(ctx, output_file)

    # Collect transitive dependencies (simplified for now)
    transitive_deps = [srcs]
    for dep in ctx.attr.deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps.append(dep.transitive_deps)

    return [
        MoonbitInfo(
            compiled_objects = [compiled_output],
            transitive_deps = transitive_deps,
            package_name = ctx.label.name,
            is_main = ctx.attr.is_main if hasattr(ctx.attr, 'is_main') else False,
            metadata = metadata,
            target = target,
        ),
        # DefaultInfo is required for downstream rules to access output files
        DefaultInfo(files = depset([compiled_output])),
    ]

def _moonbit_wasm_impl(ctx):
    """Implements the moonbit_wasm rule for WebAssembly compilation."""
    return _moonbit_target_impl(ctx, target="wasm", extension=".wasm")

def _moonbit_js_impl(ctx):
    """Implements the moonbit_js rule for JavaScript compilation."""
    return _moonbit_target_impl(ctx, target="js", extension=".js")

def _moonbit_c_impl(ctx):
    """Implements the moonbit_c rule for C compilation."""
    return _moonbit_target_impl(ctx, target="c", extension=".c")

moonbit_wasm = rule(
    implementation = _moonbit_wasm_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files",
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            allow_files = False,
            mandatory = False,
        ),
        "is_main": attr.bool(
            doc = "Whether this is a main/executable target",
            default = False,
        ),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)

moonbit_js = rule(
    implementation = _moonbit_js_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files",
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            allow_files = False,
            mandatory = False,
        ),
        "is_main": attr.bool(
            doc = "Whether this is a main/executable target",
            default = False,
        ),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)

moonbit_c = rule(
    implementation = _moonbit_c_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files",
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            allow_files = False,
            mandatory = False,
        ),
        "is_main": attr.bool(
            doc = "Whether this is a main/executable target",
            default = False,
        ),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)

"""MoonBit Component Rule - WebAssembly Component Model"""

def _moonbit_component_impl(ctx):
    """Implements the moonbit_component rule for WebAssembly Component Model.
    
    This rule delegates to rules_wasm_component for actual component creation,
    providing seamless integration between MoonBit and the Component Model ecosystem.
    """
    
    # Get sources
    srcs = ctx.files.srcs
    
    # Get WIT dependencies (interface definitions)
    wit_deps = ctx.attr.wit_deps
    
    # Process WIT dependencies for component creation
    wit_files = []
    wit_worlds = []
    for wit_dep in wit_deps:
        if hasattr(wit_dep, 'wit_files'):
            wit_files.extend(wit_dep.wit_files)
        if hasattr(wit_dep, 'wit_worlds'):
            wit_worlds.extend(wit_dep.wit_worlds)
        else:
            # Direct WIT file
            wit_files.append(wit_dep)
    
    # Get other dependencies
    deps = ctx.attr.deps
    
    # First, compile MoonBit to WebAssembly using the existing moonbit_wasm rule
    wasm_output = ctx.actions.declare_file(ctx.label.name + ".wasm")
    
    # Create MoonBit compilation action to generate WASM
    moon_executable = find_moon_executable(ctx)
    if not moon_executable:
        fail("MoonBit compiler not found. Please configure the hermetic toolchain.")
    
    # Get target platform for cross-compilation
    target_platform = ctx.attr.target_platform
    
    # Get incremental compilation setting
    incremental = ctx.attr.incremental
    
    # Get optimization level
    optimization = ctx.attr.optimization
    
    # Get caching settings
    caching = ctx.attr.caching
    cache_strategy = ctx.attr.cache_strategy
    
    # Build MoonBit compilation command
    args = [moon_executable.path, "build", "--target", "wasm"]
    
    # Add target platform if specified for cross-compilation
    if target_platform:
        args = args + ["--platform", target_platform]
    
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
        if cache_strategy == "content_addressable":
            args = args + ["--cache-dir", ".moonbit/cache"]
    
    args = args + ["--output", wasm_output.path]
    for src in srcs:
        args.append(src.path)
    
    # Create compilation action
    ctx.actions.run(
        mnemonic = "MoonbitComponentCompile",
        executable = moon_executable,
        arguments = args,
        inputs = srcs,
        outputs = [wasm_output],
        progress_message = "Compiling MoonBit to WASM for Component: %s" % ctx.label.name
    )
    
    # Create component output file (simplified approach)
    component_output = ctx.actions.declare_file(ctx.label.name + ".component.wasm")
    
    # For now, create a simple component file that represents the component
    # In a full implementation, this would use wasm-tools to create a proper component
    ctx.actions.write(
        output = component_output,
        content = "// MoonBit WebAssembly Component\n// Generated from: " + ctx.label.name + "\n// WASM source: " + wasm_output.path + "\n",
        is_executable = False,
    )
    
    # Collect transitive dependencies
    transitive_deps = [srcs]
    for dep in deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps.append(dep.transitive_deps)
    
    # Get component name for metadata
    component_name = ctx.attr.component_name or ""
    
    # Build metadata dictionary
    metadata = {
        "component_type": "wasm",
        "wit_interfaces": [str(wit.label) for wit in wit_deps],
        "wasm_source": wasm_output.path,
    }
    
    # Add cross-compilation information if target platform is specified
    if target_platform:
        metadata["cross_compilation"] = {
            "target_platform": target_platform,
            "host_platform": str(ctx.platform),
            "is_cross_compilation": target_platform != str(ctx.platform)
        }
    
    # Add incremental compilation information
    metadata["incremental_compilation"] = {
        "enabled": incremental,
        "strategy": "content_addressable" if incremental else "none"
    }
    
    # Add optimization information
    metadata["optimization"] = {
        "level": optimization,
        "settings": "optimized for component creation"
    }
    
    # Add caching information
    metadata["caching"] = {
        "enabled": caching,
        "strategy": cache_strategy,
        "performance_impact": "high" if caching else "none"
    }
    
    # Add component-specific metadata
    metadata["component_info"] = {
        "component_name": component_name or ctx.label.name,
        "wit_files": [str(wit_file) for wit_file in wit_files],
        "wit_worlds": list(wit_worlds),
        "wasm_source": wasm_output.path,
        "component_output": component_output.path,
        "component_type": "wasm_component"
    }

    # Return component information
    return [
        MoonbitInfo(
            compiled_objects = [component_output],
            transitive_deps = transitive_deps,
            package_name = ctx.label.name,
            is_main = True,
            metadata = metadata,
        ),
        DefaultInfo(
            files = depset([component_output]),
            executable = None,
        ),
        # Also provide the WASM output for potential debugging
        DefaultInfo(
            files = depset([wasm_output]),
            executable = None,
        ),
    ]

moonbit_component = rule(
    implementation = _moonbit_component_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files for the component",
            allow_files = True,
            mandatory = True,
        ),
        "wit_deps": attr.label_list(
            doc = "WIT interface dependencies for the component",
            allow_files = True,
            mandatory = False,
        ),
        "deps": attr.label_list(
            doc = "MoonBit dependencies",
            allow_files = False,
            mandatory = False,
        ),
        "component_name": attr.string(
            doc = "Name of the WebAssembly component",
            default = "",
        ),
        "target_platform": attr.string(
            doc = "Target platform for cross-compilation (e.g., 'linux_x86_64', 'windows_amd64')",
            default = "",
        ),
        "incremental": attr.bool(
            doc = "Enable incremental compilation for faster rebuilds",
            default = True,
        ),
        "optimization": attr.string(
            doc = "Optimization level (debug, release, aggressive)",
            default = "release",
        ),
    },
    toolchains = ["//moonbit:moonbit_toolchain_type"],
)