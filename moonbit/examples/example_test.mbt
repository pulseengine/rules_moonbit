// Example MoonBit test

test {
    let result = @example_lib.add(1, 2)
    assert(result == 3, "Expected 3, got \{result}")
    
    let message = @example_lib.greet("Test")
    assert(message == "Hello, Test!", "Unexpected greeting")
}
