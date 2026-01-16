"""Simple test to verify the MoonBit toolchain works"""

load("@rules_moonbit//moonbit:defs.bzl", "moonbit_library", "moonbit_binary", "moonbit_register_hermetic_toolchain")

def test_moonbit_toolchain():
    """Test that the MoonBit toolchain can be registered and used"""
    
    # Register the hermetic toolchain
    moonbit_register_hermetic_toolchain(
        name = "test_moonbit_toolchain",
        version = "0.6.33"
    )
    
    # Create a simple MoonBit library
    moonbit_library(
        name = "test_lib",
        srcs = ["test.mbt"],
        target_platform = "wasm",
        incremental = True,
        optimization = "release",
        caching = True,
    )
    
    # Create a simple MoonBit binary
    moonbit_binary(
        name = "test_bin",
        srcs = ["main.mbt"],
        deps = [":test_lib"],
        target_platform = "native",
        incremental = True,
        optimization = "release",
        caching = True,
    )
    
    return {
        "toolchain": "test_moonbit_toolchain",
        "library": ":test_lib",
        "binary": ":test_bin",
        "status": "success"
    }

# Test the toolchain registration
test_result = test_moonbit_toolchain()
print("MoonBit toolchain test completed: {}".format(test_result["status"]))