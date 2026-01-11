"""Minimal working MoonBit rule."""

# Minimal provider
MoonbitInfo = provider(
    doc = "Minimal MoonBit info",
    fields = {
        "name": "package name",
    }
)

# Minimal rule
def _minimal_moonbit_library_impl(ctx):
    return [MoonbitInfo(name = ctx.label.name)]

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
