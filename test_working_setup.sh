#!/bin/bash

# Test script to verify the rules_moonbit setup is working

echo "=== Testing rules_moonbit Setup ==="
echo ""

# Test 1: Check if basic Bazel build works
echo "Test 1: Basic Bazel functionality"
bazel version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Bazel is installed and working"
else
    echo "❌ Bazel is not installed or not in PATH"
    exit 1
fi

# Test 2: Check if rules_moonbit can be loaded
echo ""
echo "Test 2: Rules_moonbit loading"
bazel query @rules_moonbit//... > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Rules_moonbit can be loaded"
else
    echo "❌ Rules_moonbit cannot be loaded"
    echo "   Try: bazel build //moonbit:all"
    exit 1
fi

# Test 3: Check if toolchain is registered
echo ""
echo "Test 3: Toolchain registration"
bazel query @moonbit_toolchain//... > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ MoonBit toolchain is registered"
else
    echo "❌ MoonBit toolchain is not registered"
    echo "   Try: bazel build --enable_bzlmod=false --enable_workspace=true //examples/simple:simple_lib"
    exit 1
fi

# Test 4: Try building a simple example
echo ""
echo "Test 4: Building simple example"
bazel build --enable_bzlmod=false --enable_workspace=true //examples/simple:simple_lib > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Simple example builds successfully"
else
    echo "⚠️  Simple example build failed"
    echo "   This might be expected if the toolchain is not fully set up"
    echo "   Check the error message for details"
fi

# Test 5: Check toolchain files
echo ""
echo "Test 5: Toolchain files"
if [ -f "moonbit_toolchain/moon" ]; then
    echo "✅ Test toolchain executable exists"
else
    echo "❌ Test toolchain executable missing"
    echo "   Run: bazel run //:test_toolchain.sh"
fi

if [ -f "moonbit_toolchain/BUILD.bazel" ]; then
    echo "✅ Test toolchain BUILD file exists"
else
    echo "❌ Test toolchain BUILD file missing"
    echo "   Run: bazel run //:test_toolchain.sh"
fi

echo ""
echo "=== Setup Verification Complete ==="
echo ""
echo "If all tests passed, your rules_moonbit setup is working!"
echo ""
echo "Next steps:"
echo "1. Try building your own MoonBit targets"
echo "2. Explore the examples in the examples/ directory"
echo "3. Check the documentation in moonbit_toolchain/README.md"
echo ""
echo "For issues:"
echo "- Check WORKSPACE and MODULE.bazel files"
echo "- Verify toolchain registration"
echo "- Consult the README files for troubleshooting"
