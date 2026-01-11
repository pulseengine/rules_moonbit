"""Direct test of checksum registry"""

load("//moonbit/checksums:registry.bzl", 
     "get_moonbit_checksum", 
     "get_moonbit_info", 
     "get_latest_moonbit_version")

def test_checksum_registry_direct():
    """Test checksum registry directly without repository context"""
    
    # This is a simple validation that the functions can be loaded
    # In a real test, we would use repository_ctx
    
    # Verify functions exist
    assert get_moonbit_checksum != None, "get_moonbit_checksum should exist"
    assert get_moonbit_info != None, "get_moonbit_info should exist"
    assert get_latest_moonbit_version != None, "get_latest_moonbit_version should exist"
    
    return True

# Simple test that just verifies the registry can be loaded
checksum_registry_test = test_checksum_registry_direct
