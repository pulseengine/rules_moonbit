"""MoonBit rules - PUBLIC API

STABILITY: Public API

The rules and macros in this file are the public API of rules_moonbit
for MoonBit language support. They are subject to semantic versioning guarantees:
- Major version: Breaking changes allowed
- Minor version: Backwards-compatible additions  
- Patch version: Bug fixes only

DO NOT depend on //moonbit/private - those are implementation details.

Available rules:
    moonbit_library: Compile a MoonBit library
    moonbit_binary: Build a MoonBit executable
    moonbit_test: Create a MoonBit test
    moonbit_module: Build a MoonBit module
    
Example usage:

    moonbit_library(
        name = "mylib",
        srcs = ["lib.mbt"],
        deps = [":otherlib"],
    )

    moonbit_binary(
        name = "myapp",
        srcs = ["main.mbt"],
        deps = [":mylib"],
    )
"""

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

# Load private implementations with underscore prefix
load("//moonbit/private:moon.bzl", 
     _moonbit_library = "moonbit_library", 
     _moonbit_binary = "moonbit_binary", 
     _moonbit_test = "moonbit_test", 
     _moonbit_module = "moonbit_module")

load("//moonbit/private:toolchain.bzl", 
     _moonbit_toolchain = "moonbit_toolchain", 
     _moonbit_register_toolchains = "moonbit_register_toolchains")

# Load providers for public use
load("//moonbit:providers.bzl", 
     "MoonbitInfo", 
     "MoonbitToolchainInfo", 
     "MoonbitModuleInfo")

# Re-export providers for convenience
moonbit_info = MoonbitInfo
moonbit_toolchain_info = MoonbitToolchainInfo
moonbit_module_info = MoonbitModuleInfo

# Re-export rules for public API (following rules_rust pattern)
moonbit_library = _moonbit_library
moonbit_binary = _moonbit_binary
moonbit_test = _moonbit_test
moonbit_module = _moonbit_module
moonbit_toolchain = _moonbit_toolchain
moonbit_register_toolchains = _moonbit_register_toolchains
