# GitHub Repository Setup Guide for Rules_Moonbit

## Overview

This guide provides step-by-step instructions for setting up the Rules_Moonbit repository on GitHub under the PulseEngine organization.

## Prerequisites

1. **GitHub Account**: You need a GitHub account with admin access to the PulseEngine organization
2. **GitHub CLI**: Install the GitHub CLI (`gh`) for easier repository management
3. **Git**: Install Git for version control

## Step 1: Create GitHub Repository

### Using GitHub Website

1. **Log in** to your GitHub account
2. **Navigate** to the PulseEngine organization: `https://github.com/pulseengine`
3. **Click** "New repository"
4. **Configure repository**:
   - Repository name: `rules_moonbit`
   - Description: "Bazel rules for MoonBit with hermetic toolchain support"
   - Visibility: Public
   - Initialize with README: No (we have our own)
   - Add .gitignore: No (we have our own)
   - Choose a license: Apache License 2.0
5. **Click** "Create repository"

### Using GitHub CLI

```bash
# Install GitHub CLI if not installed
# brew install gh (macOS)
# sudo apt install gh (Linux)

# Authenticate
gh auth login

# Create repository
gh repo create pulseengine/rules_moonbit \
  --public \
  --description "Bazel rules for MoonBit with hermetic toolchain support" \
  --license apache-2.0
```

## Step 2: Push Local Repository to GitHub

```bash
# Add GitHub repository as remote
cd /Users/r/git/rules_moonbit
git remote add origin git@github.com:pulseengine/rules_moonbit.git

# Push main branch
git push -u origin main
```

## Step 3: Configure Repository Settings

### Branch Protection

1. Go to **Settings** > **Branches** > **Branch protection rules**
2. Click **Add rule**
3. Configure:
   - Branch name pattern: `main`
   - Require pull request reviews before merging
   - Require status checks to pass before merging
   - Include administrators
   - Restrict who can push to matching branches

### Collaborators

1. Go to **Settings** > **Manage access** > **Invite teams or people**
2. Add core team members with **Write** access
3. Add maintainers with **Admin** access

### Issues and Projects

1. Go to **Settings** > **Features**
2. Enable:
   - Issues
   - Projects
   - Wiki
   - Discussions

### CI/CD Integration

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Add any required secrets for CI/CD

## Step 4: Set Up GitHub Actions

Create `.github/workflows` directory and add CI/CD workflows:

```bash
mkdir -p .github/workflows

cat > .github/workflows/ci.yml << 'EOL'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up Bazel
      uses: bazelbuild/setup-bazelisk@v2
    - name: Build
      run: bazel build //...
    - name: Test
      run: bazel test //test/...
EOL

cat > .github/workflows/release.yml << 'EOL'
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up Bazel
      uses: bazelbuild/setup-bazelisk@v2
    - name: Build release
      run: bazel build //:all
    - name: Create release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          bazel-bin/*
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOL
```

## Step 5: Configure Repository Metadata

### Add Topics

1. Go to **Settings** > **Topics**
2. Add relevant topics:
   - `bazel`
   - `moonbit`
   - `rules-moonbit`
   - `build-system`
   - `hermetic-toolchain`

### Add Repository Description

1. Go to **Settings** > **About**
2. Update description:
   ```
   Bazel rules for MoonBit with hermetic toolchain support. Provides comprehensive build rules, cross-compilation support, and dependency management for MoonBit projects.
   ```

### Add Website and Documentation Links

1. Go to **Settings** > **About**
2. Add:
   - Website: `https://pulseengine.github.io/rules_moonbit`
   - Documentation: `https://pulseengine.github.io/rules_moonbit/docs`

## Step 6: Set Up Documentation

### GitHub Pages

1. Go to **Settings** > **Pages**
2. Configure:
   - Source: GitHub Actions
   - Build from: `.github/workflows/docs.yml`

### Create docs workflow

```bash
cat > .github/workflows/docs.yml << 'EOL'
name: Documentation

on:
  push:
    branches: [ main ]
    paths:
      - 'docs/**'
      - '.github/workflows/docs.yml'

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: 18
    - name: Install dependencies
      run: npm install
    - name: Build documentation
      run: npm run build
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build
EOL
```

## Step 7: Configure Issue Templates

```bash
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'EOL'
name: Bug Report
description: File a bug report
title: "[Bug]: "
labels: ["bug", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for reporting a bug! Please fill out the template below.
  - type: input
    id: version
    attributes:
      label: Rules_Moonbit Version
      description: What version of rules_moonbit are you using?
      placeholder: e.g., 0.1.0
  - type: input
    id: bazel-version
    attributes:
      label: Bazel Version
      description: What version of Bazel are you using?
      placeholder: e.g., 8.5.0
  - type: textarea
    id: description
    attributes:
      label: Describe the Bug
      description: A clear and concise description of what the bug is.
  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the behavior.
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: A clear and concise description of what you expected to happen.
  - type: dropdown
    id: platform
    attributes:
      label: Platform
      options:
        - macOS (Apple Silicon)
        - macOS (Intel)
        - Linux
        - Windows
        - Other
EOL

cat > .github/ISSUE_TEMPLATE/feature_request.yml << 'EOL'
name: Feature Request
description: Suggest an idea for this project
title: "[Feature]: "
labels: ["enhancement", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for suggesting a feature! Please fill out the template below.
  - type: textarea
    id: description
    attributes:
      label: Feature Description
      description: A clear and concise description of the feature you're proposing.
  - type: textarea
    id: use-case
    attributes:
      label: Use Case
      description: Describe the use case and why this feature would be valuable.
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives
      description: Describe any alternative solutions or features you've considered.
  - type: dropdown
    id: priority
    attributes:
      label: Priority
      options:
        - Low
        - Medium
        - High
EOL
```

## Step 8: Set Up Code Owners

```bash
cat > CODEOWNERS << 'EOL'
# Code owners for rules_moonbit

# Core maintainers
* @pulseengine/core-team

# Specific areas
/moonbit/checksums/ @pulseengine/toolchain-team
/moonbit/tools/ @pulseengine/toolchain-team
/moonbit/private/toolchain.bzl @pulseengine/toolchain-team

docs/ @pulseengine/docs-team

# Default to core team
* @pulseengine/core-team
EOL
```

## Step 9: Configure Dependabot

```bash
mkdir -p .github

cat > .github/dependabot.yml << 'EOL'
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "github-actions"
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "npm"
EOL
```

## Step 10: Final Verification

```bash
# Verify all files are committed
git status

# Push any remaining changes
git add .
git commit -m "Add GitHub configuration files"
git push origin main

# Verify remote tracking
git remote -v
```

## Repository Structure

After setup, your repository should have this structure:

```
rules_moonbit/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   └── feature_request.yml
│   ├── dependabot.yml
│   └── workflows/
│       ├── ci.yml
│       ├── docs.yml
│       └── release.yml
├── .gitignore
├── CODEOWNERS
├── GITHUB_SETUP.md
├── LICENSE
├── MODULE.bazel
├── README.md
├── WORKSPACE
├── moonbit/
│   ├── checksums/
│   ├── tools/
│   └── ...
├── test/
│   └── ...
└── examples/
    └── ...
```

## Maintenance Tips

1. **Regular Updates**: Keep dependencies updated
2. **Issue Triage**: Regularly review and triage issues
3. **Documentation**: Keep documentation in sync with code
4. **Security**: Monitor for security vulnerabilities
5. **Community**: Engage with the community and respond to issues

## Troubleshooting

### Common Issues

1. **Permission Issues**: Ensure you have admin access to PulseEngine organization
2. **Branch Protection**: Make sure main branch is protected before enabling CI
3. **GitHub Actions**: Check workflow syntax and permissions
4. **Repository Size**: Monitor repository size and clean up large files

### Getting Help

- GitHub Documentation: https://docs.github.com
- GitHub CLI Documentation: https://cli.github.com/manual
- Bazel Documentation: https://bazel.build

## Conclusion

Following this guide will set up a professional, well-configured GitHub repository for Rules_Moonbit under the PulseEngine organization. The repository will be ready for collaboration, CI/CD, and community contributions.
