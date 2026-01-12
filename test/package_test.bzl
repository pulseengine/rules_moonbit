"""Tests for enhanced MoonBit package registry features"""

load("//moonbit/private:package_utils.bzl", 
     "generate_package_config",
     "create_package_resolution_action",
     "create_cross_compilation_config",
     "validate_package_checksums")

def test_enhanced_package_config():
    """Test enhanced package configuration with Cargo-like features."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:package")
            self.platform = "darwin_arm64"
    
    ctx = MockContext()
    
    # Test enhanced package config
    packages = [
        {
            "name": "math",
            "version": "1.2.3",
            "features": ["advanced"],
            "platform": "linux_amd64",
            "checksum": "abc123",
            "optional": False,
        }
    ]
    
    config = generate_package_config(ctx, packages)
    
    # Verify enhanced features
    assert config["registry"]["protocol"] == "cargo-like"
    assert config["registry"]["index"] == "sparse"
    assert config["registry"]["cache"]["strategy"] == "content_addressable"
    assert config["hermeticity"]["checksum_verification"] == True
    
    # Verify package features
    math_pkg = config["packages"]["math"]
    assert math_pkg["platform"] == "linux_amd64"
    assert math_pkg["checksum"] == "abc123"
    assert math_pkg["optional"] == False
    
    print("✓ Enhanced package config test passed")

def test_cross_compilation_config():
    """Test cross-compilation configuration."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:package")
            self.platform = "darwin_arm64"
    
    ctx = MockContext()
    
    # Test cross-compilation config
    cross_config = create_cross_compilation_config(ctx, "wasm32-unknown-unknown")
    
    assert cross_config["cross_compilation"]["target"] == "wasm32-unknown-unknown"
    assert cross_config["cross_compilation"]["host"] == "//test:package"
    assert cross_config["cross_compilation"]["toolchain"] == "moonbit-wasm32-unknown-unknown"
    assert cross_config["cross_compilation"]["features"]["cross_compilation"] == True
    
    print("✓ Cross-compilation config test passed")

def test_package_resolution_enhancements():
    """Test enhanced package resolution with Cargo-like features."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:package")
    
    ctx = MockContext()
    
    # Create package config
    packages = [
        {
            "name": "test_pkg",
            "version": "1.0.0",
            "platform": "linux_amd64",
        }
    ]
    package_config = generate_package_config(ctx, packages)
    
    # Test enhanced resolution
    resolution = create_package_resolution_action(ctx, package_config)
    
    assert "conflicts" in resolution
    assert "platform_resolution" in resolution
    assert "linux_amd64" in resolution["platform_resolution"]
    assert "test_pkg" in resolution["platform_resolution"]["linux_amd64"]
    
    print("✓ Package resolution enhancements test passed")

def test_checksum_validation():
    """Test package checksum validation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:package")
    
    ctx = MockContext()
    
    # Test checksum validation
    packages = [
        {"name": "pkg1", "checksum": "abc123"},
        {"name": "pkg2", "checksum": None},  # No checksum
    ]
    
    validation = validate_package_checksums(ctx, packages)
    
    assert validation["valid"] == True
    assert len(validation["verified_packages"]) == 1
    assert "pkg1" in validation["verified_packages"]
    assert len(validation["warnings"]) == 1
    assert "pkg2" in validation["warnings"][0]
    
    print("✓ Checksum validation test passed")

def test_cargo_like_features():
    """Test that Cargo-like features are properly implemented."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:package")
    
    ctx = MockContext()
    
    # Test all Cargo-like features
    packages = [
        {
            "name": "complete_pkg",
            "version": "2.0.0",
            "features": ["feature1", "feature2"],
            "platform": "linux_amd64",
            "checksum": "checksum123",
            "optional": False,
            "conflicts": ["conflict_pkg"],
        }
    ]
    
    config = generate_package_config(ctx, packages)
    
    # Verify all features are present
    complete_pkg = config["packages"]["complete_pkg"]
    assert complete_pkg["version"] == "2.0.0"
    assert complete_pkg["features"] == ["feature1", "feature2"]
    assert complete_pkg["platform"] == "linux_amd64"
    assert complete_pkg["checksum"] == "checksum123"
    assert complete_pkg["optional"] == False
    assert complete_pkg["conflicts"] == ["conflict_pkg"]
    
    print("✓ Cargo-like features test passed")

# Run all tests
if __name__ == "__main__":
    test_enhanced_package_config()
    test_cross_compilation_config()
    test_package_resolution_enhancements()
    test_checksum_validation()
    test_cargo_like_features()
    print("\n✅ All enhanced package tests passed!")