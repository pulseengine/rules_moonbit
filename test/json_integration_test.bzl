"""Tests for JSON integration between Bazel and MoonBit"""

load("@bazel_skylib//lib:json.bzl", "to_json", "from_json")
load("//moonbit/private:json_utils.bzl", 
     "generate_bazel_to_moon_json", 
     "parse_moon_to_bazel_json",
     "generate_hermetic_build_config",
     "create_json_interop_files",
     "generate_dependency_manifest")

def test_json_generation():
    """Test JSON generation functions"""
    # Create a mock context
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            if len(parts) == 2:
                self.package = parts[0].lstrip("/")
                self.name = parts[1]
            else:
                self.package = "test"
                self.name = label_str
        
        def __str__(self):
            return "//" + self.package + ":" + self.name
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:target")
            self.workspace_name = "test_workspace"
            self.platform = "darwin_arm64"
            self.configuration = "release"
    
    # Test files and dependencies
    srcs = [MockFile("test.mbt"), MockFile("lib.mbt")]
    
    class MockDep:
        def __init__(self, label_str):
            self.label = MockLabel(label_str)
            self.metadata = {"version": "1.0.0"}
    
    deps = [MockDep("other:dep1"), MockDep("base:lib")]
    
    ctx = MockContext()
    
    # Test JSON generation
    json_config = generate_bazel_to_moon_json(ctx, srcs, deps, is_main=False)
    
    # Parse and verify
    config = from_json(json_config)
    
    assert config["bazel"]["label"] == "//test:target"
    assert config["bazel"]["package_name"] == "test"
    assert config["bazel"]["target_name"] == "target"
    assert len(config["sources"]) == 2
    assert len(config["dependencies"]) == 2
    assert config["dependencies"][0]["label"] == "//other:dep1"
    
    print("✓ JSON generation test passed")

def test_hermetic_config():
    """Test hermetic build configuration generation"""
    
    class MockPlatform:
        def __init__(self):
            self.os = "darwin"
            self.arch = "arm64"
            self.cpu = "apple_arm64"
        
        def __str__(self):
            return "darwin_arm64"
    
    class MockLabel:
        def __init__(self, name):
            self.name = name
        
        def __str__(self):
            return self.name
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test_target")
            self.platform = MockPlatform()
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    ctx = MockContext()
    output_file = MockFile("output.wasm")
    
    hermetic_config = generate_hermetic_build_config(ctx, output_file, target="wasm")
    config = from_json(hermetic_config)
    
    assert config["hermetic_build"]["bazel_version"] == "7.0.0"
    assert config["hermetic_build"]["moonbit_version"] == "0.6.33"
    assert config["hermetic_build"]["platform"]["os"] == "darwin"
    assert config["hermetic_build"]["toolchain"]["type"] == "hermetic"
    assert config["hermetic_build"]["target"] == "wasm"
    
    print("✓ Hermetic config test passed")

def test_dependency_manifest():
    """Test dependency manifest generation"""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
        
        def __str__(self):
            return "//" + self.package + ":" + self.name
    
    class MockDep:
        def __init__(self, label_str, trans_deps=None):
            self.label = MockLabel(label_str)
            self.transitive_deps = trans_deps or []
    
    deps = [
        MockDep("//other:dep1", [MockDep("//base:lib1")]),
        MockDep("//utils:helper")
    ]
    
    manifest_json = generate_dependency_manifest(deps)
    manifest = from_json(manifest_json)
    
    assert len(manifest["dependencies"]) == 2
    assert len(manifest["transitive_dependencies"]) == 1
    assert "//other:dep1" in manifest["dependency_graph"]
    assert len(manifest["dependency_graph"]["//other:dep1"]["transitive"]) == 1
    
    print("✓ Dependency manifest test passed")

def test_json_roundtrip():
    """Test JSON parsing and roundtrip"""
    
    # Sample MoonBit JSON output
    moonbit_json = """
    {
        "package_name": "test",
        "version": "1.0.0",
        "dependencies": ["//other:dep"],
        "target": "wasm",
        "optimization_level": "release",
        "source_files": ["test.mbt"],
        "output_format": "json",
        "timestamp": "2026-01-11T00:00:00Z"
    }
    """
    
    # Parse it
    bazel_json = parse_moon_to_bazel_json(moonbit_json)
    result = from_json(bazel_json)
    
    assert result["moonbit"]["version"] == "1.0.0"
    assert result["moonbit"]["target"] == "wasm"
    assert len(result["dependencies"]) == 1
    assert result["dependencies"][0] == "//other:dep"
    
    print("✓ JSON roundtrip test passed")

# Run all tests
if __name__ == "__main__":
    test_json_generation()
    test_hermetic_config()
    test_dependency_manifest()
    test_json_roundtrip()
    print("\n✅ All JSON integration tests passed!")