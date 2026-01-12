// Shared MoonBit library that works across all targets
// This demonstrates code that can be compiled to Wasm, JS, and C

// Cross-platform data structure
fn create_user(id: Int, name: String, email: String) -> {
    id: Int,
    name: String,
    email: String,
    created_at: String
} {
    {
        id: id,
        name: name,
        email: email,
        created_at: "2026-01-11T00:00:00Z"
    }
}

// Cross-platform utility functions
fn calculate_total(items: [Int]) -> Int {
    items.fold(0, fn(acc, item) { acc + item })
}

fn format_greeting(name: String) -> String {
    "Hello, " + name + "! Welcome to MoonBit multi-target compilation!"
}

// Target-specific adaptations (handled by compiler)
fn get_platform_info() -> String {
    // This will be adapted by the compiler for each target
    "Running on MoonBit multi-target platform"
}

// Complex data processing that works across targets
fn process_data(data: [{id: Int, value: String}]) -> [{id: Int, value: String, processed: Bool}] {
    data.map(fn(item) {
        {
            id: item.id,
            value: item.value.to_upper_case(),
            processed: true
        }
    })
}