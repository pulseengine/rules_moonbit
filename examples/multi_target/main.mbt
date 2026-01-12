// Main MoonBit program demonstrating multi-target compilation
// This same source can be compiled to Wasm, JS, or C

import "shared.mbt"

fn main() {
    // Create cross-platform user
    let user = create_user(1, "Multi-Target User", "user@example.com")
    println("User created: " + user.name)
    
    // Use cross-platform utilities
    let total = calculate_total([1, 2, 3, 4, 5])
    println("Total: " + total.to_string())
    
    let greeting = format_greeting("World")
    println(greeting)
    
    // Get platform-specific info
    let platform_info = get_platform_info()
    println("Platform: " + platform_info)
    
    // Process complex data
    let data = [
        {id: 1, value: "test1"},
        {id: 2, value: "test2"},
        {id: 3, value: "test3"}
    ]
    let processed = process_data(data)
    println("Processed " + processed.length().to_string() + " items")
    
    // Target-specific features would be handled by compiler
    // For example:
    // - Wasm: Web-specific APIs
    // - JS: Node.js/browser APIs  
    // - C: Native system calls
    
    println("MoonBit multi-target compilation successful!")
}