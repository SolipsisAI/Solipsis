# Solipsis

<a href="https://www.flaticon.com/free-icons/chatbot" title="chatbot icons">Chatbot icons created by Flat Icons - Flaticon</a>

- [Solipsis](#solipsis)
- [Development Setup](#development-setup)
  - [LLVM](#llvm)
    - [Ubuntu](#ubuntu)
    - [macOS](#macos)
  - [Libtorch](#libtorch)
    - [Linux](#linux)
    - [macOS](#macos-1)

# Development Setup

First, make sure `rust` and `flutter` are both installed.

Then install and set up the dependencies.

```shell
cargo install flutter_rust_bridge_codegen cbindgen just
dart pub global activate ffigen
```

## LLVM

LLVM is required for ffigen to work.

### Ubuntu

```shell
sudo apt update && sudo apt install libclang-dev

# Create a symlink in /usr/lib since that's where ffigen looks
! test -f /usr/lib/libclang.so && sudo ln -s /usr/lib/llvm-13/lib/libclang.so /usr/lib/libclang.so
```

### macOS

```shell
brew install llvm
```

## Libtorch

### Linux

This requires `libtorch`. Download from [here](https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.10.1%2Bcpu.zip).

Or:

```bash
curl -L -O https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.10.1%2Bcpu.zip
```

Then unzip into the root of your project.

```bash
unzip libtorch-cxx11-abi-shared-with-deps-1.10.1%2Bcpu.zip -d path/to/project/root
```

Then set these environment variables

```shell
export LIBTORCH=$(pwd)/libtorch
export LD_LIBRARY_PATH=${LIBTORCH}/lib:$LD_LIBRARY_PATH
```

### macOS

Go to [PyTorch](https://pytorch.org/get-started/locally/) and in Package -> LibTorch. Click on the link generated.

Or:

```bash
curl -L -O https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.10.2.zip
```

Then unzip into a directory:

```bash
mkdir -p ~/Developer/packages
unzip libtorch-macos-1.10.2.zip -d ~/Developer/packages/
```

Create a symlink:

```bash
ln -s ~/Developer/packages/libtorch/lib/libtorch_cpu.dylib /usr/local/lib/
```