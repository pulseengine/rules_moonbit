// Main MoonBit program demonstrating JSON integration
// This will be compiled using Bazel-generated JSON configuration

import "lib.mbt"

fn main() {
    let message = greet("Bazel-MoonBit Integration")
    println(message)
    
    let result = add(42, 100)
    println("Calculation result: " + result.to_string())
    
    let user = create_user_profile("JSON Integration", 1, true)
    println("User created: " + user.name + ", age: " + user.age.to_string())
    
    // This demonstrates that the JSON integration preserves all MoonBit features
    let numbers = [1, 2, 3, 4, 5]
    let doubled = numbers.map(fn(x) { x * 2 })
    println("Doubled numbers: " + doubled.to_string())
}