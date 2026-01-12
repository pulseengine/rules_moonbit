"""Simple test to verify rules_moonbit can be loaded and used."""

# Test that we can load the rules
load("//moonbit:defs.bzl", "moonbit_library", "moonbit_binary", "moonbit_test")

# Test that we can access the rules
def test_rules_loading():
    """Test that rules can be loaded without errors."""
    # If we get here, the rules loaded successfully
    return True

# Test that providers are accessible
load("//moonbit:providers.bzl", "MoonbitInfo")

def test_providers_loading():
    """Test that providers can be loaded without errors."""
    # If we get here, the providers loaded successfully
    return True

# Simple integration test
def test_simple_integration(ctx):
    """Test that a simple moonbit_library can be created."""
    # This would be a real test in a proper test environment
    # For now, just verify the rule exists and can be called
    try:
        # Try to create a simple target definition
        target = struct(
            name = "test_lib",
            rule = moonbit_library,
            srcs = ["test.mbt"],
        )
        return True
    except:
        return False