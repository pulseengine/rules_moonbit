"""Tests for FFI integration in rules_moonbit"""

load("//moonbit/private:ffi_utils.bzl", 
     "generate_ffi_configuration",
     "create_ffi_bindings",
     "generate_ffi_integration_json")

def test_ffi_configuration_generation():
    """Test FFI configuration generation for different targets."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:ffi")
    
    ctx = MockContext()
    
    # Test Wasm FFI configuration
    wasm_config = generate_ffi_configuration(ctx, "wasm", {})
    assert wasm_config["target"] == "wasm"
    assert wasm_config["ffi_type"] == "wasm"
    assert "imports" in wasm_config
    assert "exports" in wasm_config
    assert "memory" in wasm_config
    
    # Test JS FFI configuration
    js_config = generate_ffi_configuration(ctx, "js", {})
    assert js_config["target"] == "js"
    assert js_config["ffi_type"] == "javascript"
    assert "module_system" in js_config
    assert "npm_dependencies" in js_config
    
    # Test C FFI configuration
    c_config = generate_ffi_configuration(ctx, "c", {})
    assert c_config["target"] == "c"
    assert c_config["ffi_type"] == "native"
    assert "header_file" in c_config
    assert "include_paths" in c_config
    
    print("✓ FFI configuration generation test passed")

def test_ffi_bindings_creation():
    """Test FFI bindings creation for different targets."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockActions:
        def declare_file(self, name):
            return MockFile(name)
        
        def write(self, output, content, is_executable):
            # Simulate file writing
            pass
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:ffi")
            self.actions = MockActions()
    
    ctx = MockContext()
    
    # Test Wasm FFI bindings
    wasm_config = generate_ffi_configuration(ctx, "wasm", {})
    wasm_bindings = create_ffi_bindings(ctx, "wasm", wasm_config)
    
    assert "wasm" in wasm_bindings
    assert "metadata" in wasm_bindings
    assert wasm_bindings["wasm"]["header_file"].path.endswith(".ffi.wasm.h")
    
    # Test JS FFI bindings
    js_config = generate_ffi_configuration(ctx, "js", {})
    js_bindings = create_ffi_bindings(ctx, "js", js_config)
    
    assert "js" in js_bindings
    assert "metadata" in js_bindings
    assert js_bindings["js"]["bindings_file"].path.endswith(".ffi.js")
    
    # Test C FFI bindings
    c_config = generate_ffi_configuration(ctx, "c", {})
    c_bindings = create_ffi_bindings(ctx, "c", c_config)
    
    assert "c" in c_bindings
    assert "metadata" in c_bindings
    assert c_bindings["c"]["header_file"].path.endswith(".ffi.h")
    assert c_bindings["c"]["source_file"].path.endswith(".ffi.c")
    
    print("✓ FFI bindings creation test passed")

def test_ffi_integration_json():
    """Test FFI integration JSON generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:ffi")
    
    ctx = MockContext()
    
    # Test JSON generation
    wasm_config = generate_ffi_configuration(ctx, "wasm", {})
    ffi_json = generate_ffi_integration_json(ctx, "wasm", wasm_config)
    
    assert "ffi_integration" in ffi_json
    assert ffi_json["ffi_integration"]["target"] == "wasm"
    assert ffi_json["ffi_integration"]["ffi_type"] == "wasm"
    assert ffi_json["ffi_integration"]["moonbit_specific"] == True
    
    print("✓ FFI integration JSON test passed")

def test_ffi_configuration_options():
    """Test FFI configuration with custom options."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:ffi")
    
    ctx = MockContext()
    
    # Test custom Wasm options
    custom_wasm_config = generate_ffi_configuration(ctx, "wasm", {
        "imports": ["custom_import"],
        "exports": ["custom_export"],
        "memory": {"initial": 20, "maximum": 200},
    })
    
    assert "custom_import" in custom_wasm_config["imports"]
    assert "custom_export" in custom_wasm_config["exports"]
    assert custom_wasm_config["memory"]["initial"] == 20
    
    # Test custom JS options
    custom_js_config = generate_ffi_configuration(ctx, "js", {
        "module_system": "commonjs",
        "npm_dependencies": ["custom_dep"],
    })
    
    assert custom_js_config["module_system"] == "commonjs"
    assert "custom_dep" in custom_js_config["npm_dependencies"]
    
    print("✓ FFI configuration options test passed")

def test_ffi_target_coverage():
    """Test that all target platforms are covered."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:ffi")
    
    ctx = MockContext()
    
    # Test all supported targets
    targets = ["wasm", "js", "c", "native"]
    
    for target in targets:
        config = generate_ffi_configuration(ctx, target, {})
        assert config["target"] == target
        assert "ffi_type" in config
        assert config["moonbit_specific"] == True
    
    print("✓ FFI target coverage test passed")

# Run all tests
if __name__ == "__main__":
    test_ffi_configuration_generation()
    test_ffi_bindings_creation()
    test_ffi_integration_json()
    test_ffi_configuration_options()
    test_ffi_target_coverage()
    print("\n✅ All FFI integration tests passed!")