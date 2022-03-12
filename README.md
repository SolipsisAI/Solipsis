# Solipsis

<a href="https://www.flaticon.com/free-icons/chatbot" title="chatbot icons">Chatbot icons created by Flat Icons - Flaticon</a>

# Development

First, make sure `rust` and `flutter` are both installed.

Then install and set up the dependencies.

```shell
cargo install flutter_rust_bridge_codegen cbindgen just
dart pub global activate ffigen
```

## LLVM

LLVM is required for ffigen to work.

**Ubuntu**
```shell
sudo apt update && sudo apt install libclang-dev

# Create a symlink in /usr/lib since that's where ffigen looks
! test -f /usr/lib/libclang.so && sudo ln -s /usr/lib/llvm-13/lib/libclang.so /usr/lib/libclang.so
```

**macOS**
```shell
brew install llvm
```