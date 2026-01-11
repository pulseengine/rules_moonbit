"""Simplified MoonBit rule for testing."""

load("//moonbit:providers.bzl", "MoonbitInfo")

def simple_moonbit_library_impl(ctx):
    """Simple implementation for testing."""
    return [MoonbitInfo(
        compiled_objects = [],
        transitive_deps = [],
        package_name = ctx.label.name,
        is_main = False,
    )]

simple_moonbit_library = rule(
    implementation = simple_moonbit_library_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "MoonBit source files",
            allow_files = True,
            mandatory = True,
        ),
    },
)
