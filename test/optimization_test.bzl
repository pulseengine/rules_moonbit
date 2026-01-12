"""Tests for MoonBit optimization features"""

load("//moonbit/private:optimization_utils.bzl", 
     "generate_optimization_config",
     "get_c_optimization_flags",
     "get_native_optimization_flags",
     "generate_optimization_flags",
     "get_optimization_recommendations")

def test_optimization_config_generation():
    """Test optimization configuration generation for different targets and levels."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:optimize")
    
    ctx = MockContext()
    
    # Test debug optimization
    debug_config = generate_optimization_config(ctx, "wasm", "debug")
    assert debug_config["optimization_level"] == "debug"
    assert debug_config["debug_info"] == True
    assert debug_config["inlining"] == True
    
    # Test release optimization
    release_config = generate_optimization_config(ctx, "wasm", "release")
    assert release_config["optimization_level"] == "release"
    assert release_config["debug_info"] == False
    assert release_config["size_optimization"] == True
    
    # Test aggressive optimization
    aggressive_config = generate_optimization_config(ctx, "wasm", "aggressive")
    assert aggressive_config["optimization_level"] == "aggressive"
    assert aggressive_config["debug_info"] == False
    assert aggressive_config["aggressive_optimizations"] == True
    
    print("✓ Optimization config generation test passed")

def test_c_optimization_flags():
    """Test C-specific optimization flags generation."""
    
    # Test debug flags
    debug_flags = get_c_optimization_flags("debug")
    assert "-O0" in debug_flags
    assert "-g" in debug_flags
    assert "-DDEBUG" in debug_flags
    
    # Test release flags
    release_flags = get_c_optimization_flags("release")
    assert "-O2" in release_flags
    assert "-DNDEBUG" in release_flags
    
    # Test aggressive flags
    aggressive_flags = get_c_optimization_flags("aggressive")
    assert "-O3" in aggressive_flags
    assert "-flto" in aggressive_flags
    assert "-funroll-loops" in aggressive_flags
    
    print("✓ C optimization flags test passed")

def test_native_optimization_flags():
    """Test native-specific optimization flags generation."""
    
    # Test debug flags
    debug_flags = get_native_optimization_flags("debug")
    assert "-O0" in debug_flags
    assert "-g" in debug_flags
    
    # Test release flags
    release_flags = get_native_optimization_flags("release")
    assert "-O2" in release_flags
    
    # Test aggressive flags
    aggressive_flags = get_native_optimization_flags("aggressive")
    assert "-O3" in aggressive_flags
    assert "-march=native" in aggressive_flags
    
    print("✓ Native optimization flags test passed")

def test_optimization_flags_generation():
    """Test optimization flags generation for MoonBit compiler."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:optimize")
    
    ctx = MockContext()
    
    # Test Wasm optimization flags
    wasm_config = generate_optimization_config(ctx, "wasm", "release")
    wasm_flags = generate_optimization_flags(ctx, "wasm", wasm_config)
    assert "--release" in wasm_flags
    assert "--target=wasm" in wasm_flags
    
    # Test JS optimization flags
    js_config = generate_optimization_config(ctx, "js", "aggressive")
    js_flags = generate_optimization_flags(ctx, "js", js_config)
    assert "--release" in js_flags
    assert "--aggressive" in js_flags
    
    print("✓ Optimization flags generation test passed")

def test_optimization_recommendations():
    """Test optimization recommendations for different use cases."""
    
    # Test Wasm recommendations
    wasm_recommendations = get_optimization_recommendations("wasm", "general")
    assert wasm_recommendations == "release"
    
    wasm_size_recommendations = get_optimization_recommendations("wasm", "size_critical")
    assert wasm_size_recommendations == "release"
    
    wasm_performance_recommendations = get_optimization_recommendations("wasm", "performance_critical")
    assert wasm_performance_recommendations == "aggressive"
    
    # Test JS recommendations
    js_recommendations = get_optimization_recommendations("js", "general")
    assert js_recommendations == "release"
    
    # Test C recommendations
    c_recommendations = get_optimization_recommendations("c", "general")
    assert c_recommendations == "release"
    
    print("✓ Optimization recommendations test passed")

def test_target_specific_optimizations():
    """Test target-specific optimization configurations."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:optimize")
    
    ctx = MockContext()
    
    # Test Wasm-specific optimizations
    wasm_config = generate_optimization_config(ctx, "wasm", "release")
    assert "gc_optimization" in wasm_config
    assert "reference_types_optimization" in wasm_config
    
    # Test JS-specific optimizations
    js_config = generate_optimization_config(ctx, "js", "release")
    assert "tree_shaking" in js_config
    assert "minification" in js_config
    
    # Test C-specific optimizations
    c_config = generate_optimization_config(ctx, "c", "release")
    assert "lto" in c_config
    assert "link_time_optimization" in c_config
    
    print("✓ Target-specific optimizations test passed")

# Run all tests
if __name__ == "__main__":
    test_optimization_config_generation()
    test_c_optimization_flags()
    test_native_optimization_flags()
    test_optimization_flags_generation()
    test_optimization_recommendations()
    test_target_specific_optimizations()
    print("\n✅ All optimization tests passed!")