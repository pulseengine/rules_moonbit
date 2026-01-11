#!/bin/bash
set -e

echo "Testing MoonBit vendor toolchain system..."

# Test that we can load the vendor toolchain system
echo "Load test: Checking if vendor toolchain system can be loaded"
if [ -f "$TEST_SRCDIR/rules_moonbit/moonbit/tools/vendor_toolchains.bzl" ]; then
    echo "✓ Vendor toolchain file exists"
else
    echo "✗ Vendor toolchain file not found"
    exit 1
fi

# Test that the vendor system has required functions
echo "Function test: Checking for required functions"
if grep -q 'def vendor_moonbit_toolchain' "$TEST_SRCDIR/rules_moonbit/moonbit/tools/vendor_toolchains.bzl"; then
    echo "✓ vendor_moonbit_toolchain function exists"
else
    echo "✗ vendor_moonbit_toolchain function not found"
    exit 1
fi

if grep -q 'def _construct_moonbit_download_url' "$TEST_SRCDIR/rules_moonbit/moonbit/tools/vendor_toolchains.bzl"; then
    echo "✓ _construct_moonbit_download_url function exists"
else
    echo "✗ _construct_moonbit_download_url function not found"
    exit 1
fi

if grep -q 'def _vendor_moonbit_toolchain_impl' "$TEST_SRCDIR/rules_moonbit/moonbit/tools/vendor_toolchains.bzl"; then
    echo "✓ _vendor_moonbit_toolchain_impl function exists"
else
    echo "✗ _vendor_moonbit_toolchain_impl function not found"
    exit 1
fi

# Test that vendor system uses checksum registry
echo "Integration test: Checking checksum registry integration"
if grep -q 'get_moonbit_checksum' "$TEST_SRCDIR/rules_moonbit/moonbit/tools/vendor_toolchains.bzl"; then
    echo "✓ Vendor system uses checksum registry"
else
    echo "✗ Vendor system missing checksum registry integration"
    exit 1
fi

if grep -q 'get_moonbit_info' "$TEST_SRCDIR/rules_moonbit/moonbit/tools/vendor_toolchains.bzl"; then
    echo "✓ Vendor system uses tool info"
else
    echo "✗ Vendor system missing tool info integration"
    exit 1
fi

echo "All vendor toolchain tests passed!"
