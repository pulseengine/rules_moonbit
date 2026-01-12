// MoonBit library demonstrating JSON integration
// This library will be compiled with JSON configuration from Bazel

fn greet(name: String) -> String {
    "Hello, " + name + "! Welcome to MoonBit-Bazel JSON integration!"
}

fn add(a: Int, b: Int) -> Int {
    a + b
}

// This function demonstrates complex data structures that work well with JSON
fn create_user_profile(name: String, age: Int, is_active: Bool) -> {
    name: String,
    age: Int,
    is_active: Bool,
    created_at: String
} {
    {
        name: name,
        age: age,
        is_active: is_active,
        created_at: "2026-01-11T00:00:00Z"
    }
}