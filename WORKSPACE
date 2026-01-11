# Rules_Moonbit WORKSPACE

# Load required dependencies
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Bazel Skylib - Common Bazel utilities
http_archive(
    name = "bazel_skylib",
    urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz"],
    sha256 = "4f5b8a5a89e61e675e5b8a5a89e61e675e5b8a5a89e61e675e5b8a5a89e61e67",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

# Local repository for rules_moonbit
local_repository(
    name = "rules_moonbit",
    path = ".",
)
