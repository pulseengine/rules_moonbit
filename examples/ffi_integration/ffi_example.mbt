// MoonBit FFI Example
// This demonstrates MoonBit code that can be used with FFI bindings
// to interact with other languages

// Simple math functions that will be exported via FFI
fn add(a: Int, b: Int) -> Int {
    a + b
}

fn subtract(a: Int, b: Int) -> Int {
    a - b
}

fn multiply(a: Int, b: Int) -> Int {
    a * b
}

fn divide(a: Int, b: Int) -> Result(Int, String) {
    if b == 0 {
        Err("Division by zero")
    } else {
        Ok(a / b)
    }
}

// String manipulation functions
fn greet(name: String) -> String {
    "Hello, " + name + "!"
}

fn format_message(template: String, values: [String]) -> String {
    // Simple string formatting
    let result = template
    for value in values {
        result = result.replace("{}", value, 1)
    }
    result
}

// Data structure manipulation
fn process_data(items: [Int]) -> [Int] {
    items.map(fn(x) { x * 2 })
}

fn filter_data(items: [Int], threshold: Int) -> [Int] {
    items.filter(fn(x) { x > threshold })
}

// Complex data processing
fn analyze_data(items: [{id: Int, value: String}]) -> {
    count: Int,
    total: Int,
    average: Float
} {
    let count = items.length()
    let total = items.fold(0, fn(acc, item) { acc + item.id })
    let average = if count > 0 { total as Float / count as Float } else { 0.0 }
    {
        count: count,
        total: total,
        average: average
    }
}

// Export functions for FFI
// Note: In a real implementation, these would use FFI-specific export syntax
export {
    add: add,
    subtract: subtract,
    multiply: multiply,
    divide: divide,
    greet: greet,
    format_message: format_message,
    process_data: process_data,
    filter_data: filter_data,
    analyze_data: analyze_data
}