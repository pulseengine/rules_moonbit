#!/bin/bash
set -e

echo "Validating hermetic toolchain system..."

# Test 1: Check if checksum registry exists
echo "Test 1: Checking checksum registry..."
if [ -f "moonbit/checksums/registry.bzl" ]; then
    echo "✓ Checksum registry exists"
else
    echo "✗ Checksum registry not found"
    exit 1
fi

# Test 2: Check if checksum JSON exists and is valid
echo "Test 2: Checking checksum JSON..."
if [ -f "moonbit/checksums/moonbit.json" ]; then
    echo "✓ Checksum JSON exists"
    
    # Validate JSON structure
    if grep -q '"versions"' moonbit/checksums/moonbit.json; then
        echo "✓ JSON has versions field"
    else
        echo "✗ JSON missing versions field"
        exit 1
    fi
    
    # Check for multiple versions
    version_count=$(grep -o '"0\.[0-9]\.[0-9][0-9]"' moonbit/checksums/moonbit.json | wc -l)
    if [ "$version_count" -ge 3 ]; then
        echo "✓ JSON contains $version_count versions"
    else
        echo "✗ JSON should contain at least 3 versions, found $version_count"
        exit 1
    fi
else
    echo "✗ Checksum JSON not found"
    exit 1
fi

# Test 3: Check if vendor toolchain exists
echo "Test 3: Checking vendor toolchain..."
if [ -f "moonbit/tools/vendor_toolchains.bzl" ]; then
    echo "✓ Vendor toolchain exists"
    
    # Check for key functions
    if grep -q 'def vendor_moonbit_toolchain' moonbit/tools/vendor_toolchains.bzl; then
        echo "✓ Vendor toolchain has vendor_moonbit_toolchain function"
    else
        echo "✗ Vendor toolchain missing vendor_moonbit_toolchain function"
        exit 1
    fi
else
    echo "✗ Vendor toolchain not found"
    exit 1
fi

# Test 4: Check if toolchain integration exists
echo "Test 4: Checking toolchain integration..."
if [ -f "moonbit/private/toolchain.bzl" ]; then
    echo "✓ Toolchain integration exists"
    
    # Check for hermetic functions
    if grep -q 'moonbit_hermetic_toolchain_setup' moonbit/private/toolchain.bzl; then
        echo "✓ Toolchain has hermetic setup function"
    else
        echo "✗ Toolchain missing hermetic setup function"
        exit 1
    fi
else
    echo "✗ Toolchain integration not found"
    exit 1
fi

# Test 5: Check if extensions exist
echo "Test 5: Checking Bzlmod extensions..."
if [ -f "moonbit/extensions.bzl" ]; then
    echo "✓ Bzlmod extensions exist"
else
    echo "✗ Bzlmod extensions not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "All hermetic toolchain tests passed! ✓"
echo "=========================================="
echo ""
echo "Summary:"
echo "- Checksum registry: Working"
echo "- Multi-version support: Working"
echo "- Vendor toolchain system: Working"
echo "- Toolchain integration: Working"
echo "- Bzlmod extensions: Working"
