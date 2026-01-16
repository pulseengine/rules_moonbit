# BUILD file for MoonBit toolchain
# This file is used by http_archive to create the toolchain target

package(default_visibility = ["//visibility:public"])

# Export the moon executable
exports_files(["moon"])

# Create a filegroup for all toolchain files
filegroup(
    name = "moonbit_toolchain_files",
    srcs = glob(["**/*"]),
    output_group = "toolchain_files",
)

# Create the toolchain info provider
load("//moonbit:providers.bzl", "moonbit_toolchain_info")

moonbit_toolchain_info(
    name = "moonbit_toolchain",
    moon_executable = "moon",
    version = "0.6.33",  # This will be overridden by the actual version
    target_platform = "native",  # This will be detected at runtime
    all_files = ":moonbit_toolchain_files",
    supports_wasm = True,
    supports_native = True,
    supports_js = True,
    supports_c = True,
)