"""Tests for MoonBit debugging and profiling features"""

load("//moonbit/private:debug_utils.bzl", 
     "generate_debug_config",
     "create_debug_symbols_action",
     "generate_profiling_config",
     "create_profiling_instrumentation_action",
     "generate_coverage_config",
     "create_coverage_instrumentation_action",
     "generate_performance_analysis_config",
     "create_performance_analysis_action")

def test_debug_config_generation():
    """Test debug configuration generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:debug")
    
    ctx = MockContext()
    
    # Test full debug config
    full_config = generate_debug_config(ctx, "full")
    assert full_config["debug"]["level"] == "full"
    assert full_config["debug"]["symbols"] == True
    assert full_config["debug"]["source_maps"] == True
    
    # Test minimal debug config
    minimal_config = generate_debug_config(ctx, "minimal")
    assert minimal_config["debug"]["level"] == "minimal"
    assert minimal_config["debug"]["symbols"] == True
    assert minimal_config["debug"]["source_maps"] == False
    
    # Test no debug config
    none_config = generate_debug_config(ctx, "none")
    assert none_config["debug"]["level"] == "none"
    assert none_config["debug"]["symbols"] == False
    
    print("✓ Debug config generation test passed")

def test_profiling_config_generation():
    """Test profiling configuration generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:debug")
    
    ctx = MockContext()
    
    # Test detailed profiling config
    detailed_config = generate_profiling_config(ctx, "detailed")
    assert detailed_config["profiling"]["level"] == "detailed"
    assert detailed_config["profiling"]["instrumentation"]["function_calls"] == True
    assert detailed_config["profiling"]["instrumentation"]["memory_allocation"] == True
    
    # Test basic profiling config
    basic_config = generate_profiling_config(ctx, "basic")
    assert basic_config["profiling"]["level"] == "basic"
    assert basic_config["profiling"]["instrumentation"]["function_entry_exit"] == True
    
    print("✓ Profiling config generation test passed")

def test_coverage_config_generation():
    """Test coverage configuration generation."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:debug")
    
    ctx = MockContext()
    
    # Test detailed coverage config
    detailed_config = generate_coverage_config(ctx, "detailed")
    assert detailed_config["coverage"]["level"] == "detailed"
    assert detailed_config["coverage"]["instrumentation"]["branch_coverage"] == True
    
    # Test basic coverage config
    basic_config = generate_coverage_config(ctx, "basic")
    assert basic_config["coverage"]["level"] == "basic"
    assert basic_config["coverage"]["instrumentation"]["line_coverage"] == True
    
    print("✓ Coverage config generation test passed")

def test_performance_analysis_config():
    """Test performance analysis configuration."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:debug")
    
    ctx = MockContext()
    
    # Test detailed analysis config
    detailed_config = generate_performance_analysis_config(ctx, "detailed")
    assert detailed_config["performance_analysis"]["type"] == "detailed"
    assert detailed_config["performance_analysis"]["metrics"]["gc_statistics"] == True
    assert detailed_config["performance_analysis"]["metrics"]["function_timing"] == True
    
    # Test basic analysis config
    basic_config = generate_performance_analysis_config(ctx, "basic")
    assert basic_config["performance_analysis"]["type"] == "basic"
    assert basic_config["performance_analysis"]["metrics"]["execution_time"] == True
    
    print("✓ Performance analysis config test passed")

def test_debug_symbols_generation():
    """Test debug symbols generation."""
    
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
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:debug")
            self.actions = MockActions()
    
    ctx = MockContext()
    
    # Test debug symbols with full config
    full_config = generate_debug_config(ctx, "full")
    symbols = create_debug_symbols_action(ctx, "wasm", full_config)
    
    assert "symbols_file" in symbols
    assert symbols["symbols_file"].path.endswith(".debug")
    assert symbols["source_map"] is not None
    assert symbols["coverage_data"] is not None
    
    print("✓ Debug symbols generation test passed")

def test_comprehensive_debug_profiling():
    """Test comprehensive debug and profiling integration."""
    
    class MockLabel:
        def __init__(self, label_str):
            parts = label_str.split(":")
            self.package = parts[0].lstrip("/")
            self.name = parts[1]
    
    class MockContext:
        def __init__(self):
            self.label = MockLabel("test:debug")
    
    ctx = MockContext()
    
    # Generate all configurations
    debug_config = generate_debug_config(ctx, "full")
    profiling_config = generate_profiling_config(ctx, "detailed")
    coverage_config = generate_coverage_config(ctx, "detailed")
    analysis_config = generate_performance_analysis_config(ctx, "detailed")
    
    # Generate comprehensive report
    report = generate_debug_profiling_report(ctx, debug_config, profiling_config, coverage_config, analysis_config)
    
    assert "debug_profiling" in report
    assert report["debug_profiling"]["debug"]["level"] == "full"
    assert report["debug_profiling"]["profiling"]["level"] == "detailed"
    assert report["debug_profiling"]["coverage"]["level"] == "detailed"
    assert report["debug_profiling"]["performance_analysis"]["type"] == "detailed"
    
    print("✓ Comprehensive debug profiling test passed")

# Run all tests
if __name__ == "__main__":
    test_debug_config_generation()
    test_profiling_config_generation()
    test_coverage_config_generation()
    test_performance_analysis_config()
    test_debug_symbols_generation()
    test_comprehensive_debug_profiling()
    print("\n✅ All debug and profiling tests passed!")