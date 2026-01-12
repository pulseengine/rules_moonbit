"""Tests for advanced MoonBit toolchain features"""

load("//moonbit/private:toolchain_utils.bzl", 
     "generate_toolchain_config",
     "create_toolchain_validation_action",
     "get_toolchain_version_info",
     "create_toolchain_extensions",
     "generate_toolchain_documentation")

def test_toolchain_config_generation():
    """Test toolchain configuration generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:toolchain")
    
    ctx = MockContext()
    
    # Test default toolchain config
    default_config = generate_toolchain_config(ctx)
    assert default_config["version"] == "0.6.33"
    assert default_config["checksum_verification"] == True
    assert default_config["hermetic"] == True
    assert "wasm_support" in default_config["features"]
    assert "js_support" in default_config["features"]
    
    # Test custom toolchain config
    custom_config = generate_toolchain_config(ctx, "0.6.32", {"custom_feature": True})
    assert custom_config["version"] == "0.6.32"
    assert custom_config["features"]["custom_feature"] == True
    
    print("✓ Toolchain config generation test passed")

def test_toolchain_validation():
    """Test toolchain validation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:toolchain")
    
    ctx = MockContext()
    
    # Test validation with good config
    good_config = generate_toolchain_config(ctx)
    good_validation = create_toolchain_validation_action(ctx, good_config)
    assert good_validation["valid"] == True
    assert len(good_validation["errors"]) == 0
    
    # Test validation with bad config (unsupported version)
    bad_config = generate_toolchain_config(ctx, "0.5.0")
    bad_validation = create_toolchain_validation_action(ctx, bad_config)
    # Should still be valid but with warnings
    assert bad_validation["valid"] == True
    
    print("✓ Toolchain validation test passed")

def test_version_info():
    """Test version information lookup."""
    
    # Test known version
    version_0_6_33 = get_toolchain_version_info("0.6.33")
    assert version_0_6_33["release_date"] == "2024-03-15"
    assert version_0_6_33["stability"] == "stable"
    assert version_0_6_33["recommended"] == True
    assert "wasm_gc" in version_0_6_33["features"]
    
    # Test unknown version
    unknown_version = get_toolchain_version_info("99.99.99")
    assert unknown_version["stability"] == "unknown"
    assert unknown_version["recommended"] == False
    
    print("✓ Version info test passed")

def test_toolchain_extensions():
    """Test toolchain extensions."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:toolchain")
    
    ctx = MockContext()
    
    # Create base config
    base_config = generate_toolchain_config(ctx)
    
    # Create extensions
    extensions = {
        "features": {"new_feature": True},
        "platforms": {"new_platform": {"supported": True, "tested": False}},
    }
    
    # Apply extensions
    extended_config = create_toolchain_extensions(ctx, base_config, extensions)
    assert extended_config["features"]["new_feature"] == True
    assert "new_platform" in extended_config["platforms"]
    
    print("✓ Toolchain extensions test passed")

def test_toolchain_documentation():
    """Test toolchain documentation generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:toolchain")
    
    ctx = MockContext()
    
    # Create toolchain config
    toolchain_config = generate_toolchain_config(ctx)
    
    # Generate documentation
    documentation = generate_toolchain_documentation(ctx, toolchain_config)
    
    assert "toolchain" in documentation
    assert "version_info" in documentation
    assert "validation" in documentation
    assert documentation["toolchain"]["version"] == "0.6.33"
    
    print("✓ Toolchain documentation test passed")

# Run all tests
if __name__ == "__main__":
    test_toolchain_config_generation()
    test_toolchain_validation()
    test_version_info()
    test_toolchain_extensions()
    test_toolchain_documentation()
    print("\n✅ All toolchain tests passed!")