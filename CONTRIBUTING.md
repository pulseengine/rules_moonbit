# Contributing to Rules_Moonbit

Welcome to rules_moonbit! We appreciate your interest in contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch** for your changes

```bash
git clone https://github.com/your-username/rules_moonbit.git
cd rules_moonbit
git checkout -b feature/your-feature-name
```

## Development Setup

### Prerequisites

- Bazel (latest version)
- MoonBit toolchain
- Python 3.x
- Basic build tools

### Building

```bash
# Build all targets
bazel build //...

# Run tests
bazel test //...
```

## Contribution Guidelines

### Code Style

- Follow existing code patterns and conventions
- Use descriptive variable and function names
- Add comments for complex logic
- Keep functions focused and small

### Commit Messages

- Use clear, descriptive commit messages
- Follow conventional commits format
- Reference related issues when applicable

### Pull Requests

1. **Create a draft PR** early to get feedback
2. **Ensure all tests pass** before requesting review
3. **Update documentation** for any new features
4. **Address review comments** promptly

### Testing

- Add tests for new functionality
- Ensure existing tests continue to pass
- Test on multiple platforms when possible

## Code Review Process

1. **Initial Review**: Maintainers will review your PR within 3-5 business days
2. **Feedback Iteration**: Address any review comments
3. **Approval**: Once approved, your PR will be merged
4. **Release**: Changes will be included in the next release

## Reporting Issues

- Use GitHub Issues to report bugs or request features
- Provide clear reproduction steps for bugs
- Include relevant environment information
- Be responsive to follow-up questions

## Community

- Join our discussion channels (link to be added)
- Participate in design discussions
- Help review other contributions
- Share your use cases and feedback

## License

By contributing to rules_moonbit, you agree that your contributions will be licensed under the Apache License 2.0.
