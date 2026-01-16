# Simple MoonBit toolchain for basic functionality

load("@bazel_tools//tools/build_defs/core:native.bzl", "native")

# Define a simple toolchain type
moonbit_toolchain_type = native.toolchain_type(
    name = "moonbit_toolchain_type",
    toolchain_name = "moonbit"
)

# Simple toolchain implementation
def _simple_moonbit_toolchain_impl(ctx):
    """Simple MoonBit toolchain implementation."""
    # For now, just return basic toolchain info
    # In a real implementation, this would find the moon executable
    return []

# Simple toolchain rule
simple_moonbit_toolchain = rule(
    implementation = _simple_moonbit_toolchain_impl,
    attrs = {},
    toolchains = [moonbit_toolchain_type]
)

# Register toolchains function
def register_simple_toolchains(target):
    """Register simple MoonBit toolchains."""
    native.register_toolchains(target)