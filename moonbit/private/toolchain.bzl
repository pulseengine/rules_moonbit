"""MoonBit toolchain implementation with hermetic tool management"""

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
load("//moonbit/tools:vendor_toolchains.bzl", "vendor_moonbit_toolchain")

def moonbit_toolchain_impl(ctx):
    """Implements the MoonBit toolchain rule with hermetic support."""
    
    # Option 1: Use hermetic toolchain from vendor system
    # This would be the preferred approach in production
    
    # Option 2: Fallback to system installation
    moon_executable = None
    try:
        moon_path = ctx.which("moon")
        if moon_path:
            moon_executable = moon_path
    except:
        pass
    
    # For now, return basic toolchain info
    # In production, this would use the hermetic toolchain
    return [MoonbitToolchainInfo(
        moon_executable = moon_executable,
        version = "0.6.33",  # Would come from hermetic toolchain
        target_platform = "native",
        all_files = [],
        supports_wasm = True,
        supports_native = True,
    )]

moonbit_toolchain = rule(
    implementation = moonbit_toolchain_impl,
    attrs = {},
)

def moonbit_register_toolchains(
    name = "moonbit_toolchains",
    moon_executable = None,
    version = None,
    target_platform = None,
):
    """Registers MoonBit toolchains for use in the workspace.
    
    This function provides two approaches:
    1. Hermetic toolchain using vendor system (recommended)
    2. System toolchain using existing installation
    
    Args:
        name: Name for the toolchain registration
        moon_executable: Optional explicit path to moon executable
        version: Optional version override
        target_platform: Optional target platform override
    
    Example (Hermetic approach - recommended):
        load("//moonbit/tools:vendor_toolchains.bzl", "vendor_moonbit_toolchain")
        
        vendor_moonbit_toolchain(name = "moonbit_vendor")
        
        moonbit_register_toolchains(
            name = "moonbit_toolchains",
            moon_executable = "@moonbit_vendor//:moon",
        )
    
    Example (System approach - for development):
        moonbit_register_toolchains(
            name = "moonbit_toolchains",
        )
    """
    # For now, this is a placeholder
    # In a real implementation, this would:
    # 1. Register the toolchain with Bazel
    # 2. Set up platform mappings
    # 3. Configure toolchain resolution
    pass

# Hermetic toolchain vendor function for MODULE.bazel
# This would be used in the main MODULE.bazel file
def moonbit_hermetic_toolchain_setup():
    """Sets up hermetic MoonBit toolchain using Bzlmod extensions.
    
    This function is designed to be used in MODULE.bazel:
    
    Example:
        moonbit_setup = use_extension("//moonbit:extensions.bzl", "moonbit_hermetic_toolchain_setup")
        use_repo(moonbit_setup, "moonbit_toolchains")
    """
    # This would be implemented using use_extension
    # For now, it's a placeholder for the Bzlmod approach
    vendor_moonbit_toolchain(name = "moonbit_hermetic")
    
    return struct(
        toolchain_repo = "@moonbit_hermetic",
        toolchain_target = "@moonbit_hermetic//:moon",
    )
