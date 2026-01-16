# MoonBit Test Toolchain

This directory contains a test toolchain for MoonBit that can be used for development and testing when the real MoonBit compiler is not available.

## Usage

### Option 1: Using the Test Toolchain (Recommended for Development)

1. **Create the test toolchain** (already done):
   ```bash
   bazel run //:test_toolchain.sh
   ```

2. **Update your WORKSPACE file** to use the local toolchain:
   ```bazel
   # In your WORKSPACE file:
   local_repository(
       name = "moonbit_toolchain",
       path = "moonbit_toolchain",
   )
   
   register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
   ```

3. **Build your project**:
   ```bash
   bazel build //your/target:here
   ```

### Option 2: Using the Hermetic Toolchain (When Available)

When the real MoonBit compiler becomes available:

1. **Update the checksum registry** with correct URLs and checksums:
   - Edit `moonbit/checksums/moonbit.json`
   - Add the correct SHA256 checksums for each platform
   - Verify the download URLs are correct

2. **Use the hermetic toolchain in WORKSPACE**:
   ```bazel
   load("//moonbit/tools:hermetic_toolchain.bzl", "moonbit_toolchain_repository")
   
   moonbit_toolchain_repository(
       name = "moonbit_toolchain",
       version = "0.6.33",  # or your desired version
   )
   
   register_toolchains("@moonbit_toolchain//:moonbit_toolchain")
   ```

### Option 3: Using a Local MoonBit Installation

If you have MoonBit installed locally:

1. **Create a custom toolchain BUILD file**:
   ```bazel
   # In a custom BUILD file:
   exports_files(["path/to/your/moon"])
   
   filegroup(
       name = "moonbit_toolchain",
       srcs = ["path/to/your/moon"],
   )
   ```

2. **Register your custom toolchain**:
   ```bazel
   local_repository(
       name = "custom_moonbit_toolchain",
       path = "path/to/your/build/file",
   )
   
   register_toolchains("@custom_moonbit_toolchain//:moonbit_toolchain")
   ```

## Toolchain Contents

- `moon` - Placeholder MoonBit compiler executable
- `BUILD.bazel` - Bazel build file defining the toolchain
- `WORKSPACE` - WORKSPACE file for the toolchain
- `README.md` - This file

## Troubleshooting

### "MoonBit compiler not found" Errors

If you see errors about the MoonBit compiler not being found:

1. **Check your toolchain registration** in WORKSPACE
2. **Verify the repository exists** with `bazel query @moonbit_toolchain//...`
3. **Ensure the toolchain is registered** with `bazel query @moonbit_toolchain//:moonbit_toolchain`

### Download Failures

If the hermetic toolchain fails to download:

1. **Check your internet connectivity**
2. **Verify the MoonBit release exists** at the specified URL
3. **Check GitHub rate limits** (you may be rate-limited)
4. **Use the test toolchain** as a fallback

### Platform Not Supported

If your platform is not supported:

1. **Check the supported platforms** in `moonbit/checksums/moonbit.json`
2. **Add your platform** to the checksum registry if it should be supported
3. **Use the test toolchain** for development
4. **Consider contributing** platform support to the project

## Development Notes

The test toolchain creates dummy output files that simulate MoonBit compilation. This allows you to:

- Test the build system without the real compiler
- Develop rules and build logic
- Verify toolchain resolution works
- Test cross-platform builds

When the real MoonBit compiler becomes available, simply switch to the hermetic toolchain or local installation method.

## Contributing

If you want to help improve the MoonBit toolchain:

1. **Update checksums** when new MoonBit versions are released
2. **Add support for new platforms** as they become available
3. **Improve error handling** and user experience
4. **Add more comprehensive tests**
5. **Document best practices** for MoonBit development

## License

This test toolchain is provided under the Apache License 2.0, same as the main rules_moonbit project.