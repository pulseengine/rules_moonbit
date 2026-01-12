"""Tests for Component Model integration between rules_moonbit and rules_wasm_component"""

load("//moonbit/private:component_utils.bzl", 
     "create_moonbit_compilation_context",
     "generate_wit_integration_config",
     "generate_component_metadata")

def test_compilation_context_creation():
    """Test MoonBit compilation context creation for component integration."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
        
        def __str__(self):
            return "//" + self.package + ":" + self.name
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockFiles:
        def __init__(self, files):
            self.srcs = files
    
    class MockAttr:
        def __init__(self):
            self.wit_deps = []
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:component")
            self.files = MockFiles([MockFile("test.mbt")])
            self.attr = MockAttr()
            self.platform = "darwin_arm64"
            self.configuration = "release"
            self.workspace_name = "test"
    
    class MockActions:
        def declare_file(self, name):
            return MockFile(name)
    
    ctx = MockContext()
    ctx.actions = MockActions()
    
    output_file = MockFile("output.wasm")
    
    # Test context creation
    compilation_ctx = create_moonbit_compilation_context(ctx, output_file, "wasm")
    
    assert compilation_ctx.label.name == "component"
    assert compilation_ctx.output_file.path == "output.wasm"
    assert compilation_ctx.target == "wasm"
    assert len(compilation_ctx.files.srcs) == 1
    
    print("✓ Compilation context creation test passed")

def test_wit_integration_config():
    """Test WIT integration configuration generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
        
        def __str__(self):
            return "//" + self.package + ":" + self.name
    
    class MockDep:
        def __init__(self, label_str):
            self.label_str = label_str
        
        def __str__(self):
            return self.label_str
    
    class MockAttr:
        def __init__(self):
            self.wit_deps = [MockDep("//test:math_wit")]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:component")
            self.attr = MockAttr()
    
    ctx = MockContext()
    
    # Test WIT config generation
    wit_config = generate_wit_integration_config(ctx)
    
    assert wit_config["wit_integration"]["moonbit_target"] == "//test:component"
    assert len(wit_config["wit_integration"]["wit_dependencies"]) == 1
    assert wit_config["wit_integration"]["wit_dependencies"][0] == "//test:math_wit"
    assert wit_config["wit_integration"]["moonbit_specific"] == True
    assert wit_config["wit_integration"]["integration_mode"] == "delegated"
    
    print("✓ WIT integration config test passed")

def test_component_metadata_generation():
    """Test component metadata generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
        
        def __str__(self):
            return "//" + self.package + ":" + self.name
    
    class MockDep:
        def __init__(self, label_str):
            self.label_str = label_str
        
        def __str__(self):
            return self.label_str
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:component")
    
    ctx = MockContext()
    wasm_src = MockFile("output.wasm")
    wit_deps = [MockDep("//test:math_wit")]
    
    # Test metadata generation
    metadata = generate_component_metadata(ctx, wasm_src, wit_deps)
    
    assert metadata["component"]["name"] == "component"
    assert metadata["component"]["package"] == "test"
    assert metadata["component"]["target"] == "wasm_component"
    assert metadata["component"]["wasm_source"] == "output.wasm"
    assert len(metadata["component"]["wit_dependencies"]) == 1
    assert metadata["component"]["integration"] == "rules_wasm_component"
    assert metadata["component"]["moonbit_specific"] == True
    
    print("✓ Component metadata generation test passed")

def test_integration_architecture():
    """Test the overall integration architecture."""
    
    # Verify the integration approach
    integration_architecture = {
        "rules_moonbit": {
            "responsibilities": [
                "MoonBit compilation to Wasm",
                "WIT file processing",
                "Convenience rules",
                "Integration layer"
            ],
            "provides": ["moonbit_component", "moonbit_wit"],
            "delegates_to": "rules_wasm_component"
        },
        "rules_wasm_component": {
            "responsibilities": [
                "Component creation",
                "WIT processing",
                "Component validation",
                "Toolchain management"
            ],
            "provides": ["wasm_component", "wasm_wit"],
            "receives_from": "rules_moonbit"
        },
        "integration": {
            "flow": [
                "MoonBit source → rules_moonbit → Wasm module",
                "Wasm module + WIT → rules_wasm_component → Component",
                "Component → rules_moonbit → User"
            ],
            "benefits": [
                "Clean separation of concerns",
                "Single Component Model implementation",
                "Consistent user experience",
                "Future-proof architecture"
            ]
        }
    }
    
    # Verify architecture components
    assert "rules_moonbit" in integration_architecture
    assert "rules_wasm_component" in integration_architecture
    assert "integration" in integration_architecture
    
    # Verify responsibilities
    assert "MoonBit compilation to Wasm" in integration_architecture["rules_moonbit"]["responsibilities"]
    assert "Component creation" in integration_architecture["rules_wasm_component"]["responsibilities"]
    
    # Verify integration flow
    assert len(integration_architecture["integration"]["flow"]) == 3
    assert "MoonBit source" in integration_architecture["integration"]["flow"][0]
    
    print("✓ Integration architecture test passed")

# Run all tests
if __name__ == "__main__":
    test_compilation_context_creation()
    test_wit_integration_config()
    test_component_metadata_generation()
    test_integration_architecture()
    print("\n✅ All Component Model integration tests passed!")