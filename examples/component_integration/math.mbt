// MoonBit implementation of math component
// This code will be compiled to WebAssembly and then converted to a component
// by rules_wasm_component using the WIT interface definition

// Note: In a real implementation, this would use the generated bindings
// from the WIT file. For this example, we implement the functions directly.

fn add(a: UInt32, b: UInt32) -> UInt32 {
    a + b
}

fn subtract(a: UInt32, b: UInt32) -> UInt32 {
    a - b
}

fn multiply(a: UInt32, b: UInt32) -> UInt32 {
    a * b
}

fn divide(a: UInt32, b: UInt32) -> (UInt32, UInt32) {
    let result = a / b
    let remainder = a % b
    (result, remainder)
}

// Export the functions to match the WIT interface
// In a real implementation, this would use the generated bindings
export {
    add: add,
    subtract: subtract,
    multiply: multiply,
    divide: divide
}