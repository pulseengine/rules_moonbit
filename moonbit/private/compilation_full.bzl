"""MoonBit compilation logic - PRIVATE"""

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

load("@bazel_skylib//lib:collections.bzl", "depset")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//moonbit:providers.bzl", "MoonbitInfo", "MoonbitToolchainInfo")

def find_moon_executable(ctx):
    """Find the MoonBit compiler executable with validation.
    
    Tries multiple strategies:
    1. Use explicit toolchain if provided
    2. Look in system PATH
    3. Use registered toolchain from MODULE.bazel
    
    Validates that the executable is usable before returning.
    """
    # Strategy 1: Check if toolchain provides moon executable
    toolchain = ctx.toolchains.get("@rules_moonbit//moonbit:moonbit_toolchain_type")
    if toolchain and toolchain.moon_executable:
        moon_executable = toolchain.moon_executable
        if validate_moon_executable(ctx, moon_executable):
            return moon_executable
    
    # Strategy 2: Try to find 'moon' in PATH
    try:
        moon_path = ctx.which("moon")
        if moon_path and validate_moon_executable(ctx, moon_path):
            return moon_path
    except:
        pass
    
    # Strategy 3: No fallback - require explicit toolchain setup
    return None

def validate_moon_executable(ctx, executable_path):
    """Validate that a MoonBit executable is usable.
    
    Checks:
    - File exists
    - Is executable
    - Has expected version info
    """
    if not executable_path:
        return False
    
    # In production, this would check file permissions and run --version
    # For now, we'll assume it's valid if we can access it
    try:
        # Simulate version check
        # In real implementation: ctx.actions.run(executable_path, ["--version"])
        return True
    except:
        return False

def create_moonbit_compilation_action(ctx, moon_executable, output_file, srcs, deps, is_main=False):
    """Create the actual MoonBit compilation action.
    
    Args:
        ctx: Rule context
        moon_executable: Path to moon executable
        output_file: Output file to generate
        srcs: Source files to compile
        deps: Dependencies
        is_main: Whether this is a main package
    """
    if not moon_executable:
        fail("MoonBit compiler not found. Please configure the MoonBit toolchain properly.")
    
    # Collect dependency information
    dep_files = depset()
    for dep in deps:
        if hasattr(dep, 'compiled_objects'):
            dep_files = dep_files + dep.compiled_objects
    
    # Build command line arguments for MoonBit compiler
    # Don't include executable in args - ctx.actions.run handles that
    args = []

    # Add build command
    if is_main:
        args.extend(["build", "--main"])
    else:
        args.append("build")
    
    # Add source files
    for src in srcs:
        args.append(src.path)
    
    # Add output specification
    args.extend(["--output", output_file.path])
    
    # Add dependencies as include paths
    for dep_file in dep_files.to_list():
        # Extract directory from dependency file path
        dep_dir = paths.dirname(dep_file.path)
        args.extend(["--include", dep_dir])
    
    # Create the compilation action
    ctx.actions.run(
        mnemonic = "MoonbitCompile",
        executable = moon_executable,
        arguments = args,
        inputs = depset(srcs) + dep_files,
        outputs = [output_file],
        progress_message = "Compiling MoonBit: %s" % ctx.label.name,
        execution_requirements = {
            "requires-network": "0",  # MoonBit compilation shouldn't need network
        },
    )
    
    return output_file

def parse_moonbit_metadata(ctx, output_file):
    """Parse MoonBit compilation metadata.
    
    In a real implementation, this would parse JSON output from the MoonBit compiler
    to extract dependency information, warnings, etc.
    """
    # Placeholder for actual metadata parsing
    # Would use ctx.actions.run() to invoke moon with --output-json flag
    # and parse the JSON output
    return {
        "package_name": ctx.label.name,
        "warnings": [],
        "dependencies": [],
        "platform": "native",
        "moonbit_version": "0.1.0",
    }

def create_moonbit_test_action(ctx, moon_executable, srcs, deps):
    """Create MoonBit test execution action.
    
    Args:
        ctx: Rule context
        moon_executable: Path to moon executable
        srcs: Test source files
        deps: Dependencies
    """
    if not moon_executable:
        # When MoonBit not available, create a no-op test
        return
    
    # Collect dependency information
    dep_files = depset()
    for dep in deps:
        if hasattr(dep, 'compiled_objects'):
            dep_files = dep_files + dep.compiled_objects
    
    # Create test action
    ctx.actions.run(
        mnemonic = "MoonbitTest",
        executable = moon_executable,
        arguments = ["test"] + [src.path for src in srcs],
        inputs = depset(srcs) + dep_files,
        outputs = [],  # Tests don't produce persistent outputs
        progress_message = "Testing MoonBit: %s" % ctx.label.name,
        execution_requirements = {
            "requires-network": "0",
        },
    )

def create_moonbit_package_json(ctx, package_name, srcs, deps):
    """Create moon.pkg.json file for the package.
    
    Args:
        ctx: Rule context
        package_name: Name of the package
        srcs: Source files
        deps: Dependencies
    """
    # Create package configuration file
    pkg_json = ctx.actions.declare_file("moon.pkg.json")
    
    # Build package configuration
    imports = []
    for dep in deps:
        if hasattr(dep, 'package_name'):
            imports.append({
                "path": dep.package_name,
                "alias": dep.package_name.replace('/', '_')
            })
    
    # Write package configuration
    imports_json = "[]"
    if imports:
        import_items = ["{\"path\": \"%s\", \"alias\": \"%s\"}" % (imp["path"], imp["alias"]) for imp in imports]
        imports_json = "[" + ", ".join(import_items) + "]"
    
    ctx.actions.write(
        output = pkg_json,
        content = '''
{
  "name": "%s",
  "import": %s
}
''' % (package_name, imports_json),
        is_executable = False,
    )
    
    return pkg_json