"""Direct test of private module"""

load("//moonbit/private:moon.bzl", "moonbit_library")

def test_direct_impl(ctx):
    env = analysistest.begin(ctx)
    
    analysistest.target(
        name = "direct_lib",
        rule = moonbit_library,
        srcs = ["test.mbt"],
    )
    
    target = analysistest.target_under_test(env)
    return analysistest.end(env)

test_direct = analysistest.make(test_direct_impl)
