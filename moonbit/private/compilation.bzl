"""MoonBit compilation logic - PRIVATE"""

load("//moonbit:providers.bzl", "MoonbitInfo")

def find_moon_executable(ctx):
    return None

def create_moonbit_compilation_action(ctx, moon_executable, output_file, srcs, deps, is_main=False):
    if not moon_executable:
        ctx.actions.write(
            output = output_file,
            content = "// MoonBit compilation placeholder\n",
            is_executable = is_main,
        )
    return output_file

def parse_moonbit_metadata(ctx, output_file):
    return {"package_name": ctx.label.name}

def create_moonbit_test_action(ctx, moon_executable, srcs, deps):
    pass
