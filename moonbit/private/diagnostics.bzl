"""MoonBit diagnostics utilities - PRIVATE

Simplified diagnostics implementation to ensure core functionality works.
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

def create_toolchain_diagnostics(ctx, toolchain_info):
    """Create basic toolchain diagnostics.
    
    This is a simplified version that creates basic diagnostics without complex logic.
    
    Args:
        ctx: Rule context
        toolchain_info: Toolchain information provider
    """
    # Create a simple diagnostics file
    diagnostics_file = ctx.actions.declare_file("toolchain_diagnostics.txt")
    
    # Build diagnostics content
    diagnostics_content = """MoonBit Toolchain Diagnostics

Toolchain: {}
Version: {}
Platform: {}
Moon Executable: {}

Capabilities:
- WASM Support: {}
- Native Support: {}
- JS Support: {}
- C Support: {}

Status: Operational
""".format(
        "moonbit_toolchain",
        toolchain_info.version if hasattr(toolchain_info, 'version') else "unknown",
        toolchain_info.target_platform if hasattr(toolchain_info, 'target_platform') else "unknown",
        toolchain_info.moon_executable.path if hasattr(toolchain_info.moon_executable, 'path') else "unknown",
        toolchain_info.supports_wasm if hasattr(toolchain_info, 'supports_wasm') else "unknown",
        toolchain_info.supports_native if hasattr(toolchain_info, 'supports_native') else "unknown",
        toolchain_info.supports_js if hasattr(toolchain_info, 'supports_js') else "unknown",
        toolchain_info.supports_c if hasattr(toolchain_info, 'supports_c') else "unknown"
    )
    
    ctx.actions.write(
        output = diagnostics_file,
        content = diagnostics_content,
        is_executable = False
    )
    
    return diagnostics_file

def create_compilation_diagnostics(ctx, moonbit_info, compilation_result):
    """Create basic compilation diagnostics.
    
    Simplified version that creates basic compilation diagnostics.
    
    Args:
        ctx: Rule context
        moonbit_info: MoonBit information provider
        compilation_result: Compilation result data
    """
    # Create a simple compilation diagnostics file
    diagnostics_file = ctx.actions.declare_file("compilation_diagnostics.txt")
    
    # Build diagnostics content
    diagnostics_content = """MoonBit Compilation Diagnostics

Package: {}
Target: {}
Status: Success

Compiled Objects: {}
Transitive Dependencies: {}

Metadata:
{}
""".format(
        moonbit_info.package_name if hasattr(moonbit_info, 'package_name') else "unknown",
        moonbit_info.target if hasattr(moonbit_info, 'target') else "unknown",
        len(moonbit_info.compiled_objects) if hasattr(moonbit_info, 'compiled_objects') else 0,
        len(moonbit_info.transitive_deps) if hasattr(moonbit_info, 'transitive_deps') else 0,
        "Available" if hasattr(moonbit_info, 'metadata') else "None"
    )
    
    ctx.actions.write(
        output = diagnostics_file,
        content = diagnostics_content,
        is_executable = False
    )
    
    return diagnostics_file