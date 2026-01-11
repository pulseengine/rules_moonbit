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

load("//moonbit:providers.bzl", "MoonbitInfo")
load("//moonbit/private:compilation.bzl", 
     "find_moon_executable", 
     "create_moonbit_compilation_action", 
     "parse_moonbit_metadata",
     "create_moonbit_test_action")

"""MoonBit Library Rule"""

def _moonbit_library_impl(ctx):
    """Implements the moonbit_library rule."""
    # Get sources
    srcs = ctx.files.srcs
    
    # Find MoonBit executable
    moon_executable = find_moon_executable(ctx)
    
    # Determine output file
    output_file = ctx.actions.declare_file("%s.compiled" % ctx.label.name)
    
    # Create compilation action
    compiled_output = create_moonbit_compilation_action(
        ctx, moon_executable, output_file, srcs, ctx.attr.deps, is_main=False
    )
    
    # Parse metadata
    metadata = parse_moonbit_metadata(ctx, output_file)
    
    # Collect transitive dependencies
    transitive_deps = depset(srcs)
    for dep in ctx.attr.deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps = transitive_deps + dep.transitive_deps
    
    return [MoonbitInfo(
        compiled_objects = depset([compiled_output]),
        transitive_deps = transitive_deps,
        package_name = ctx.label.name,
        is_main = False,
        metadata = metadata,
    )]

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
    },
)

"""MoonBit Binary Rule"""

def _moonbit_binary_impl(ctx):
    """Implements the moonbit_binary rule."""
    # Get sources
    srcs = ctx.files.srcs
    
    # Find MoonBit executable
    moon_executable = find_moon_executable(ctx)
    
    # Determine output file (executable)
    output_file = ctx.actions.declare_file("%s.exe" % ctx.label.name)
    
    # Create compilation action
    compiled_output = create_moonbit_compilation_action(
        ctx, moon_executable, output_file, srcs, ctx.attr.deps, is_main=True
    )
    
    # Parse metadata
    metadata = parse_moonbit_metadata(ctx, output_file)
    
    # Collect transitive dependencies
    transitive_deps = depset(srcs)
    for dep in ctx.attr.deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps = transitive_deps + dep.transitive_deps
    
    return [MoonbitInfo(
        compiled_objects = depset([compiled_output]),
        transitive_deps = transitive_deps,
        package_name = ctx.label.name,
        is_main = True,
        metadata = metadata,
    )]

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
    },
)

"""MoonBit Test Rule"""

def _moonbit_test_impl(ctx):
    """Implements the moonbit_test rule."""
    # Get sources
    srcs = ctx.files.srcs
    
    # Find MoonBit executable
    moon_executable = find_moon_executable(ctx)
    
    # Create test action
    create_moonbit_test_action(ctx, moon_executable, srcs, ctx.attr.deps)
    
    # Get dependencies
    deps = ctx.attr.deps
    
    # Collect transitive dependencies
    transitive_deps = depset(srcs)
    for dep in deps:
        if hasattr(dep, 'transitive_deps'):
            transitive_deps = transitive_deps + dep.transitive_deps
    
    return [MoonbitInfo(
        compiled_objects = depset(),
        transitive_deps = transitive_deps,
        package_name = ctx.label.name,
        is_main = False,
        metadata = {"test_type": "moonbit"},
    )]

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

"""MoonBit Module Rule"""

def _moonbit_module_impl(ctx):
    """Implements the moonbit_module rule."""
    return [MoonbitInfo(
        compiled_objects = depset(),
        transitive_deps = depset(),
        package_name = ctx.label.name,
        is_main = False,
        metadata = {},
    )]

moonbit_module = rule(
    implementation = _moonbit_module_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Module source files and packages",
            allow_files = True,
            mandatory = False,
        ),
    },
)
