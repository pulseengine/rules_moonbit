"""MoonBit toolchain implementation - PRIVATE"""

# Copyright 2026 The Rules_Moonbit Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//moonbit:providers.bzl", "MoonbitToolchainInfo")
# For now, we'll use a simpler approach without complex toolchain registration
# The toolchain functionality will be provided through the MoonbitToolchainInfo provider


def moonbit_toolchain_impl(ctx):
    """Implements the MoonBit toolchain rule."""
    
    # Get version from attributes
    version = ctx.attr.version if hasattr(ctx.attr, 'version') else "0.6.33"
    
    # For now, use placeholder executable since we don't have actual MoonBit
    # In production, this would find the actual moon executable
    moon_executable = "moon"  # Placeholder
    
    # Create toolchain info
    toolchain_info = MoonbitToolchainInfo(
        moon_executable = moon_executable,
        version = version,
        target_platform = "native",
        all_files = [moon_executable],
        supports_wasm = True,
        supports_native = True,
        supports_js = True,
        supports_c = True,
    )
    
    return [toolchain_info]

# Export the toolchain rule
moonbit_toolchain = rule(
    implementation = moonbit_toolchain_impl,
    attrs = {
        "version": attr.string(
            doc = "MoonBit version",
            default = "0.6.33",
        ),
    },

)


def moonbit_register_toolchains(
    name = "moonbit_toolchains",
    moon_executable = None,
    version = None,
    target_platform = None
):
    """Registers MoonBit toolchains for use in the workspace."""
    # For now, this is a placeholder
    # In a real implementation, this would register the toolchain with Bazel
    # using native.toolchain() or similar mechanism
    pass
