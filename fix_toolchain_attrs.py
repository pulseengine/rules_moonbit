#!/usr/bin/env python3

import re

# Read the file
with open('moonbit/private/moon.bzl', 'r') as f:
    content = f.read()

# Remove all occurrences of the hermetic toolchain attribute
# Pattern matches the attribute definition across multiple lines
pattern = r'"_moonbit_hermetic_toolchain": attr\.label\(\s+doc = "Hermetic MoonBit toolchain \(internal use\)",\s+allow_files = False,\s+mandatory = False,\s+default = None,\s+\),'

# Remove the pattern
content_fixed = re.sub(pattern, '', content, flags=re.MULTILINE | re.DOTALL)

# Write the fixed content
with open('moonbit/private/moon.bzl', 'w') as f:
    f.write(content_fixed)

print("Fixed moon.bzl file")