// MoonBit math library for optimization examples
// This contains various functions that can benefit from different optimization strategies

// Simple arithmetic functions (good for inlining)
fn add(a: Int, b: Int) -> Int {
    a + b
}

fn subtract(a: Int, b: Int) -> Int {
    a - b
}

fn multiply(a: Int, b: Int) -> Int {
    a * b
}

// Complex mathematical functions (good for loop optimization)
fn factorial(n: Int) -> Int {
    if n <= 1 {
        1
    } else {
        n * factorial(n - 1)
    }
}

fn fibonacci(n: Int) -> Int {
    if n <= 1 {
        n
    } else {
        fibonacci(n - 1) + fibonacci(n - 2)
    }
}

// Array operations (good for loop unrolling and vectorization)
fn sum_array(arr: [Int]) -> Int {
    arr.fold(0, fn(acc, x) { acc + x })
}

fn map_array(arr: [Int], func: fn(Int) -> Int) -> [Int] {
    arr.map(func)
}

fn filter_array(arr: [Int], predicate: fn(Int) -> Bool) -> [Int] {
    arr.filter(predicate)
}

// String operations (good for constant propagation)
fn concatenate_strings(strs: [String]) -> String {
    strs.fold("", fn(acc, s) { acc + s })
}

fn repeat_string(s: String, times: Int) -> String {
    let result = ""
    for i in 0..times {
        result = result + s
    }
    result
}

// Data structure operations (good for memory optimization)
fn process_data(items: [{id: Int, value: String}]) -> [String] {
    items.map(fn(item) { item.value.to_upper_case() })
}

fn filter_data(items: [{id: Int, value: String}], threshold: Int) -> [{id: Int, value: String}] {
    items.filter(fn(item) { item.id > threshold })
}

// Export all functions
export {
    add: add,
    subtract: subtract,
    multiply: multiply,
    factorial: factorial,
    fibonacci: fibonacci,
    sum_array: sum_array,
    map_array: map_array,
    filter_array: filter_array,
    concatenate_strings: concatenate_strings,
    repeat_string: repeat_string,
    process_data: process_data,
    filter_data: filter_data
}