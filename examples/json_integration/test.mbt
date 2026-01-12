// MoonBit test demonstrating JSON integration
// This test will be executed using Bazel-generated JSON test configuration

import "lib.mbt"

test "greet function" {
    let result = greet("Test")
    assert_eq(result, "Hello, Test! Welcome to MoonBit-Bazel JSON integration!")
}

test "add function" {
    let result = add(2, 3)
    assert_eq(result, 5)
}

test "user profile creation" {
    let user = create_user_profile("Test User", 25, true)
    assert_eq(user.name, "Test User")
    assert_eq(user.age, 25)
    assert_eq(user.is_active, true)
    assert_eq(user.created_at, "2026-01-11T00:00:00Z")
}

test "json integration preserves functionality" {
    // This test verifies that all MoonBit features work through JSON integration
    let data = [1, 2, 3]
    let mapped = data.map(fn(x) { x * 2 })
    let filtered = mapped.filter(fn(x) { x > 2 })
    
    assert_eq(filtered.length(), 2)
    assert_eq(filtered[0], 4)
    assert_eq(filtered[1], 6)
}