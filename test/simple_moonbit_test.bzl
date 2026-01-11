"""Simple test for MoonBit rules."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest")
load("//moonbit/private:simple_moon.bzl", "simple_moonbit_library")

def simple_moonbit_test_impl(ctx):
    """Test simple MoonBit library."""
    env = analysistest.begin(ctx)
    
    analysistest.target(
        name = "simple_lib",
        rule = simple_moonbit_library,
        srcs = ["test.mbt"],
    )
    
    target = analysistest.target_under_test(env)
    
    if target == None:
        analysistest.fail(env, "Target should be created")
    
    return analysistest.end(env)

simple_moonbit_test = analysistest.make(simple_moonbit_test_impl)
