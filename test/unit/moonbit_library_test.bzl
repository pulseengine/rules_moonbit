"""Unit tests for moonbit_library rule."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest")
load("@rules_moonbit//moonbit:defs.bzl", "moonbit_library")

def _moonbit_library_test_impl(ctx):
    """Test basic moonbit_library functionality."""
    env = analysistest.begin(ctx)
    
    # Create a simple library target
    analysistest.target(
        name = "test_lib",
        rule = moonbit_library,
        srcs = ["test.mbt"],
    )
    
    # Analyze the target
    target = analysistest.target_under_test(env)
    
    # Verify the target was created successfully
    if target == None:
        fail("Target should be created")
    
    # Verify it has the expected outputs
    if not hasattr(target, "compiled"):
        fail("Should have compiled output")
    
    return analysistest.end(env)

moonbit_library_test = analysistest.make(_moonbit_library_test_impl)
