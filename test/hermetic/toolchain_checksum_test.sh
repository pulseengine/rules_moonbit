#!/bin/bash
set -e

echo "Testing MoonBit checksum registry..."

# Test that we can load the checksum registry
echo "Load test: Checking if checksum registry can be loaded"
if [ -f "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/registry.bzl" ]; then
    echo "✓ Checksum registry file exists"
else
    echo "✗ Checksum registry file not found"
    exit 1
fi

# Test that we can load the checksum JSON
echo "JSON test: Checking if checksum JSON can be loaded"
if [ -f "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/moonbit.json" ]; then
    echo "✓ Checksum JSON file exists"
    
    # Validate JSON structure
    if grep -q '"versions"' "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/moonbit.json"; then
        echo "✓ JSON has versions field"
    else
        echo "✗ JSON missing versions field"
        exit 1
    fi
    
    # Check for specific version
    if grep -q '"0.6.33"' "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/moonbit.json"; then
        echo "✓ JSON contains version 0.6.33"
    else
        echo "✗ JSON missing version 0.6.33"
        exit 1
    fi
    
    # Check for multiple versions
    if grep -q '"0.6.32"' "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/moonbit.json"; then
        echo "✓ JSON contains version 0.6.32"
    else
        echo "✗ JSON missing version 0.6.32"
        exit 1
    fi
    
    # Check for platform support
    if grep -q '"darwin_arm64"' "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/moonbit.json"; then
        echo "✓ JSON contains darwin_arm64 platform"
    else
        echo "✗ JSON missing darwin_arm64 platform"
        exit 1
    fi
    
    if grep -q '"linux_amd64"' "$TEST_SRCDIR/rules_moonbit/moonbit/checksums/moonbit.json"; then
        echo "✓ JSON contains linux_amd64 platform"
    else
        echo "✗ JSON missing linux_amd64 platform"
        exit 1
    fi
else
    echo "✗ Checksum JSON file not found"
    exit 1
fi

echo "All checksum registry tests passed!"
