"""Test MoonBit compiler integration"""

def test_compiler_integration():
    """Test that compiler integration works correctly."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockActions:
        def run(self, **kwargs):
            # Simulate successful compilation
            return MockFile(kwargs["outputs"][0])
        
        def declare_file(self, name):
            return MockFile(name)
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:target")
            self.actions = MockActions()
            self.toolchains = {}
    
    # Test compiler integration
    ctx = MockContext()
    moon_executable = MockFile("/usr/bin/moon")
    output_file = MockFile("output.wasm")
    srcs = [MockFile("test.mbt")]
    
    # This should work without errors
    from moonbit.private.compilation.bzl.full import create_moonbit_compilation_action
    result = create_moonbit_compilation_action(ctx, moon_executable, output_file, srcs, [], False)
    
    assert result is not None
    assert result.path == "output.wasm"
    
    print("✓ Compiler integration test passed")

if __name__ == "__main__":
    test_compiler_integration()