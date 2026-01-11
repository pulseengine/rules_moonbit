"""Simple test to verify hermetic toolchain components exist"""

def test_hermetic_components():
    """Test that hermetic toolchain components can be loaded"""
    
    # Test checksum registry
    try:
        load("//moonbit/checksums:registry.bzl", 
             "get_moonbit_checksum", 
             "get_moonbit_info", 
             "get_latest_moonbit_version")
        print("✓ Checksum registry loaded successfully")
    except Exception as e:
        print("✗ Failed to load checksum registry:", str(e))
        return False
    
    # Test vendor toolchain
    try:
        load("//moonbit/tools:vendor_toolchains.bzl", "vendor_moonbit_toolchain")
        print("✓ Vendor toolchain loaded successfully")
    except Exception as e:
        print("✗ Failed to load vendor toolchain:", str(e))
        return False
    
    # Test toolchain
    try:
        load("//moonbit/private:toolchain.bzl", 
             "moonbit_toolchain", 
             "moonbit_register_toolchains")
        print("✓ Toolchain loaded successfully")
    except Exception as e:
        print("✗ Failed to load toolchain:", str(e))
        return False
    
    return True

simple_hermetic_test = test_hermetic_components
