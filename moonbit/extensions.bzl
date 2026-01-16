"""MoonBit Bzlmod extensions"""

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

load("//moonbit/tools:hermetic_toolchain.bzl", "moonbit_register_hermetic_toolchain")

"""MoonBit Bzlmod extension for hermetic toolchain setup.

This extension provides a way to set up hermetic MoonBit toolchains
using Bzlmod's use_extension mechanism.
"""

"""MoonBit Bzlmod extensions

This provides module extensions for MoonBit toolchain setup.
"""

load("//moonbit/tools:hermetic_toolchain.bzl", "moonbit_register_hermetic_toolchain")

def _moonbit_toolchain_extension_impl(module_ctx):
    """MoonBit toolchain extension implementation.
    
    Args:
        module_ctx: Module extension context
        
    Returns:
        Extension metadata
    """
    # Create the hermetic toolchain repository directly
    moonbit_toolchain_repository(
        name = "moonbit_toolchain",
        version = "latest",
    )
    
    return module_ctx.extension_metadata(
        root_module_direct_deps = ["moonbit_toolchain"],
        root_module_direct_dev_deps = [],
    )

# Export the extension
moonbit_toolchain_extension = module_extension(
    doc = "MoonBit toolchain extension for hermetic toolchain setup",
    implementation = _moonbit_toolchain_extension_impl,
)
