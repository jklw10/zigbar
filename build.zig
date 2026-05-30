const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Build the ZBar C library from source
    // In modern Zig, we use addLibrary with .linkage = .static
    const zbar_c_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zbar",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true, // Replaces deprecated linkLibC()
        }),
    });

    // Add include directories to the library's root module
    zbar_c_lib.root_module.addIncludePath(b.path("deps/zbar"));
    zbar_c_lib.root_module.addIncludePath(b.path("deps/zbar/include"));
    zbar_c_lib.root_module.addIncludePath(b.path("deps/zbar/zbar"));

    // Common compiler flags for ZBar C compilation
    const c_flags = &[_][]const u8{
        "-std=c99",
        "-DHAVE_CONFIG_H",          // Tells ZBar to load our deps/zbar/config.h
        "-D_CRT_SECURE_NO_WARNINGS", // Suppress Windows MSVC-like warnings
    };

    // Compile the essential C files required for ZBar core + QR/Barcode decoders
    zbar_c_lib.root_module.addCSourceFiles(.{
        .root = b.path("deps/zbar"),
        .files = &.{
            // Core ZBar engine
            "zbar/config.c",
            "zbar/error.c",
            "zbar/symbol.c",
            "zbar/image.c",
            "zbar/convert.c",
            "zbar/refcnt.c",
            "zbar/img_scanner.c",
            "zbar/scanner.c",
            "zbar/decoder.c",

            // Common barcode decoders
            "zbar/decoder/ean.c",
            "zbar/decoder/code128.c",
            "zbar/decoder/code39.c",
            "zbar/decoder/i25.c",

            // QR code decoder (decoder interface + raw engine)
            "zbar/decoder/qr_finder.c",
            "zbar/qrcode/bch15_5.c",
            "zbar/qrcode/binarize.c",
            "zbar/qrcode/isaac.c",
            "zbar/qrcode/qrdec.c",
            "zbar/qrcode/qrdectxt.c",
            "zbar/qrcode/rs.c",
            "zbar/qrcode/util.c",
        },
        .flags = c_flags,
    });

    // 2. Translate your local C header file (no external dependency needed)
    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("deps/zbar/include/zbar.h"),
        .target = target,
        .optimize = optimize,
    });
    translate_c.addIncludePath(b.path("deps/zbar/include"));

    // 3. Define your Zig module
    const zigbar_module = b.addModule("zigbar", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Make the translated bindings available as @import("c") in root.zig
    zigbar_module.addImport("c", translate_c.createModule());
    zigbar_module.addIncludePath(b.path("deps/zbar/include"));

    // Link our freshly compiled ZBar static library directly into the module
    // This allows any downstream project importing this module to inherit the link configuration.
    zigbar_module.linkLibrary(zbar_c_lib);
    b.installArtifact(zbar_c_lib);
}