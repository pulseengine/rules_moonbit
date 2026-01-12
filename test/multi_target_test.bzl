"""Tests for multi-target MoonBit compilation"""

load("//moonbit/private:platforms.bzl", 
     "get_platform_config", 
     "get_bazel_consumer_rules",
     "get_output_extension", 
     "get_bazel_target_type",
     "get_ffi_type",
     "generate_target_specific_json",
     "get_ffi_integration_rules",
     "generate_bazel_integration_config",
     "get_target_from_label")

def test_platform_configurations():
    """Test platform configuration definitions"""
    
    # Test Wasm platform
    wasm_config = get_platform_config("wasm")
    assert wasm_config["name"] == "WebAssembly"
    assert wasm_config["extension"] == ".wasm"
    assert wasm_config["bazel_target"] == "wasm"
    assert "wasm_binary" in wasm_config["consumer_rules"]
    assert wasm_config["ffi_type"] == "wasm"
    
    # Test JS platform
    js_config = get_platform_config("js")
    assert js_config["name"] == "JavaScript"
    assert js_config["extension"] == ".js"
    assert js_config["bazel_target"] == "js"
    assert "js_library" in js_config["consumer_rules"]
    assert js_config["ffi_type"] == "javascript"
    assert js_config["module_system"] == "esm"
    
    # Test C platform
    c_config = get_platform_config("c")
    assert c_config["name"] == "C"
    assert c_config["extension"] == ".c"
    assert c_config["bazel_target"] == "cc"
    assert "cc_library" in c_config["consumer_rules"]
    assert c_config["ffi_type"] == "native"
    assert c_config["header_extension"] == ".h"
    
    print("✓ Platform configurations test passed")

def test_bazel_consumer_rules():
    """Test Bazel consumer rules for each target"""
    
    wasm_rules = get_bazel_consumer_rules("wasm")
    assert "wasm_binary" in wasm_rules
    assert "wasm_library" in wasm_rules
    
    js_rules = get_bazel_consumer_rules("js")
    assert "js_library" in js_rules
    assert "js_binary" in js_rules
    assert "js_test" in js_rules
    
    c_rules = get_bazel_consumer_rules("c")
    assert "cc_library" in c_rules
    assert "cc_binary" in c_rules
    assert "cc_test" in c_rules
    
    print("✓ Bazel consumer rules test passed")

def test_output_extensions():
    """Test output file extensions"""
    
    assert get_output_extension("wasm") == ".wasm"
    assert get_output_extension("js") == ".js"
    assert get_output_extension("c") == ".c"
    assert get_output_extension("native") == ""
    
    print("✓ Output extensions test passed")

def test_bazel_target_types():
    """Test Bazel target type mapping"""
    
    assert get_bazel_target_type("wasm") == "wasm"
    assert get_bazel_target_type("js") == "js"
    assert get_bazel_target_type("c") == "cc"
    assert get_bazel_target_type("native") == "cc"
    
    print("✓ Bazel target types test passed")

def test_ffi_types():
    """Test FFI type mapping"""
    
    assert get_ffi_type("wasm") == "wasm"
    assert get_ffi_type("js") == "javascript"
    assert get_ffi_type("c") == "native"
    assert get_ffi_type("native") == "native"
    
    print("✓ FFI types test passed")

def test_ffi_integration_rules():
    """Test FFI integration rules"""
    
    wasm_ffi = get_ffi_integration_rules("wasm")
    assert "wasm_ffi" in wasm_ffi
    assert "js_ffi" in wasm_ffi
    
    js_ffi = get_ffi_integration_rules("js")
    assert "js_ffi" in js_ffi
    assert "nodejs_ffi" in js_ffi
    
    c_ffi = get_ffi_integration_rules("c")
    assert "cc_ffi" in c_ffi
    assert "native_ffi" in c_ffi
    
    print("✓ FFI integration rules test passed")

def test_target_specific_json():
    """Test target-specific JSON generation"""
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockLabel:
        def __init__(self, name):
            self.name = name
        
        def __str__(self):
            return self.name
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:target")
            self.platform = "darwin_arm64"
    
    ctx = MockContext()
    output_file = MockFile("output.wasm")
    
    # Test Wasm target JSON
    wasm_json = generate_target_specific_json(ctx, "wasm", output_file)
    assert wasm_json["target_specific"]["target_type"] == "wasm"
    assert wasm_json["target_specific"]["bazel_integration"]["target_type"] == "wasm"
    assert "wasm_binary" in wasm_json["target_specific"]["bazel_integration"]["consumer_rules"]
    
    # Test JS target JSON
    js_output = MockFile("output.js")
    js_json = generate_target_specific_json(ctx, "js", js_output)
    assert js_json["target_specific"]["target_type"] == "js"
    assert js_json["target_specific"]["javascript"]["module_format"] == "esm"
    
    # Test C target JSON
    c_output = MockFile("output.c")
    c_json = generate_target_specific_json(ctx, "c", c_output)
    assert c_json["target_specific"]["target_type"] == "c"
    assert c_json["target_specific"]["c"]["header_file"] == "output.h"
    
    print("✓ Target-specific JSON test passed")

def test_bazel_integration_config():
    """Test Bazel integration configuration generation"""
    
    class MockFile:
        def __init__(self, path):
            self.path = path
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
        
        def __str__(self):
            return "//" + self.package + ":" + self.name
    
    class MockAttr:
        def __init__(self):
            self.deps = []
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:target")
            self.attr = MockAttr()
    
    ctx = MockContext()
    
    # Test Wasm integration config
    wasm_output = MockFile("output.wasm")
    wasm_config = generate_bazel_integration_config("wasm", wasm_output, ctx)
    assert wasm_config["bazel_integration"]["target_platform"] == "wasm"
    assert wasm_config["bazel_integration"]["output_type"] == "binary"
    assert wasm_config["bazel_integration"]["integration_method"] == "wasm_module"
    
    # Test JS integration config
    js_output = MockFile("output.js")
    js_config = generate_bazel_integration_config("js", js_output, ctx)
    assert js_config["bazel_integration"]["target_platform"] == "js"
    assert js_config["bazel_integration"]["javascript"]["js_module_name"] == "target"
    
    # Test C integration config
    c_output = MockFile("output.c")
    c_config = generate_bazel_integration_config("c", c_output, ctx)
    assert c_config["bazel_integration"]["target_platform"] == "c"
    assert c_config["bazel_integration"]["c"]["header_file"] == "output.h"
    
    print("✓ Bazel integration config test passed")

def test_target_detection():
    """Test automatic target detection"""
    
    class MockPlatform:
        def __init__(self, platform_str):
            self.platform_str = platform_str
        
        def __str__(self):
            return self.platform_str
    
    class MockLabel:
        def __init__(self, name):
            self.name = name
    
    class MockContext:
        def __init__(self, platform_str):
            self.label = MockLabel("test")
            self.platform = MockPlatform(platform_str)
    
    # Test Windows platform detection
    windows_ctx = MockContext("windows_amd64")
    assert get_target_from_label(windows_ctx) == "native"
    
    # Test Linux platform detection
    linux_ctx = MockContext("linux_amd64")
    assert get_target_from_label(linux_ctx) == "wasm"
    
    # Test macOS platform detection
    mac_ctx = MockContext("darwin_arm64")
    assert get_target_from_label(mac_ctx) == "wasm"
    
    print("✓ Target detection test passed")

# Run all tests
if __name__ == "__main__":
    test_platform_configurations()
    test_bazel_consumer_rules()
    test_output_extensions()
    test_bazel_target_types()
    test_ffi_types()
    test_ffi_integration_rules()
    test_target_specific_json()
    test_bazel_integration_config()
    test_target_detection()
    print("\n✅ All multi-target tests passed!")