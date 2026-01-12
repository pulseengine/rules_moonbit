"""Minimal working MoonBit rule."""

load("//moonbit:providers.bzl", "MoonbitInfo")

# Minimal rule
def _minimal_moonbit_library_impl(ctx):
    return [MoonbitInfo(
        compiled_objects = [],
        transitive_deps = [],
        package_name = ctx.label.name,
        is_main = False,
        metadata = {},
    )]

minimal_moonbit_library = rule(
    implementation = _minimal_moonbit_library_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Source files",
            allow_files = True,
            mandatory = True,
        ),
    },
)
