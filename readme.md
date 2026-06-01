# zigbar

A lightweight, zero-dependency Zig wrapper for the ZBar barcode and QR code reader.

- **Zero-Dependency Installation**: Compiles the core ZBar C engine directly from source using the Zig compiler.
- **Static Linking**: Compiles down into a single static binary.

### 2. Compile from Source
Because the library compiles ZBar directly with `zig build`, building for any platform  is straightforward.

**Build for your current host:**
```bash
zig build
```
