# zigbar

A lightweight, zero-dependency Zig wrapper for the ZBar barcode and QR code reader, fully cross-compatible with Windows, macOS, and iOS.

## Features
- **Zero-Dependency Installation**: Compiles the core ZBar C engine directly from source using the Zig compiler. No precompiled libraries, MSYS2, or Xcode dependencies required.
- **Static Linking**: Compiles down into a single static binary for easy deployment.

## Getting Started

### 1. Add as a Dependency
In your project's `build.zig.zon`, add `zigbar` as a dependency:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .zigbar = .{
            .url = "git+https://github.com/yourusername/zigbar#<COMMIT_HASH>",
            .hash = "<DEPENDENCY_HASH>",
        },
    },
    .paths = .{ "" },
}
```

Then expose it in your `build.zig`:

```zig
const zigbar_dep = b.dependency("zigbar", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zigbar", zigbar_dep.module("zigbar"));
```

### 2. Compile from Source
Because the library compiles ZBar directly with `zig build`, building for any platform (including cross-compilation) is straightforward.

**Build for your current host:**
```bash
zig build
```

**Cross-compile for Windows (x86_64):**
```bash
zig build -Dtarget=x86_64-windows
```

**Cross-compile for iOS (ARM64 physical device):**
```bash
zig build -Dtarget=aarch64-ios
```
