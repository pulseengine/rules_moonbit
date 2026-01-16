# Rules_Moonbit WORKSPACE

# Load required dependencies
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Bazel Skylib - Common Bazel utilities
http_archive(
    name = "bazel_skylib",
    urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz"],
    sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

# Local repository for rules_moonbit
local_repository(
    name = "rules_moonbit",
    path = ".",
)

# Register MoonBit toolchains using local test toolchain
# Use the test toolchain we created for development/testing
local_repository(
    name = "moonbit_toolchain",
    path = "moonbit_toolchain",
)

# Register the toolchain
register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
