"""Provider definitions for MoonBit rules"""

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

"""Provider definitions for MoonBit rules

STABILITY: Public API

These providers are the public API for MoonBit rules and are subject to
semantic versioning guarantees.
"""

# Provider for MoonBit package information
MoonbitInfo = provider(
    doc = "Information about a MoonBit package",
    fields = {
        "compiled_objects": "Depset of compiled MoonBit objects",
        "transitive_deps": "Depset of transitive dependencies",
        "package_name": "MoonBit package name",
        "is_main": "Whether this is a main package",
        "metadata": "Package metadata dict",
    },
)

# Provider for MoonBit toolchain information
MoonbitToolchainInfo = provider(
    doc = "Information about the MoonBit toolchain",
    fields = {
        "moon_executable": "MoonBit compiler executable",
        "version": "MoonBit version string",
        "target_platform": "Target platform for compilation",
        "all_files": "All toolchain files",
        "supports_wasm": "Whether WASM target is supported",
        "supports_native": "Whether native target is supported",
    },
)

# Provider for MoonBit module information
MoonbitModuleInfo = provider(
    doc = "Information about a MoonBit module",
    fields = {
        "module_name": "Module name",
        "version": "Module version",
        "packages": "Dict of package names to MoonbitInfo",
        "dependencies": "List of module dependencies",
        "metadata": "Module metadata dict",
    },
)
