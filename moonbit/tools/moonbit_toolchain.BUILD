# BUILD file for MoonBit toolchain extracted via http_archive

package(default_visibility = ["//visibility:public"])

# Export the moon executable
exports_files(["moon"])

# Create a filegroup for all toolchain files
filegroup(
    name = "moonbit_toolchain_files",
    srcs = ["moon"],
    output_group = "toolchain_files",
)