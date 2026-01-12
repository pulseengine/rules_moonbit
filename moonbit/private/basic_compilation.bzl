"""Basic MoonBit compilation logic - PRIVATE"""

load("//moonbit:providers.bzl", "MoonbitInfo")

def find_moon_executable(ctx):
    """Find MoonBit executable from system PATH."""
    # For now, return None since we don't have MoonBit compiler available
    # In a real implementation, this would find the moon executable
    return None

def create_basic_compilation_action(ctx, output_file, srcs):
    """Create a basic MoonBit compilation action."""
    moon_executable = find_moon_executable(ctx)
    
    if not moon_executable:
        # Create a placeholder file if MoonBit is not available
        ctx.actions.write(
            output = output_file,
            content = "// MoonBit compilation placeholder\n",
            is_executable = False
        )
        return output_file
    
    # Simple compilation command
    args = [moon_executable.path, "build", "--output", output_file.path]
    
    # Add source files
    for src in srcs:
        args.append(src.path)
    
    # Create compilation action
    ctx.actions.run(
        mnemonic = "MoonbitCompile",
        executable = moon_executable,
        arguments = args,
        inputs = srcs,
        outputs = [output_file],
        progress_message = "Compiling MoonBit: %s" % ctx.label.name
    )
    
    return output_file

def parse_basic_metadata(ctx):
    """Parse basic metadata."""
    return {
        "package_name": ctx.label.name,
        "warnings": [],
        "dependencies": []
    }

def create_basic_test_action(ctx, srcs):
    """Create a basic test action."""
    moon_executable = find_moon_executable(ctx)
    
    if not moon_executable:
        return
    
    # Create test action
    args = ["test"]
    for src in srcs:
        args.append(src.path)
    
    ctx.actions.run(
        mnemonic = "MoonbitTest",
        executable = moon_executable,
        arguments = args,
        inputs = srcs,
        outputs = [],
        progress_message = "Testing MoonBit: %s" % ctx.label.name
    )