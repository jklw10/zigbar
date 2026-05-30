const std = @import("std");

// Replaces the deprecated @cImport block
const c = @import("c");

pub const Error = error{
    InitializationFailed,
    ScanFailed,
};

/// Represents the ZBar scanner context.
pub const Scanner = struct {
    raw: *c.zbar_image_scanner_t,

    pub fn init() Error!Scanner {
        const raw = c.zbar_image_scanner_create() orelse return error.InitializationFailed;
        
        // Configure ZBar to enable all common decoders by default
        _ = c.zbar_image_scanner_set_config(raw, c.ZBAR_NONE, c.ZBAR_CFG_ENABLE, 1);
        
        return .{ .raw = raw };
    }

    pub fn deinit(self: *Scanner) void {
        c.zbar_image_scanner_destroy(self.raw);
    }

    /// Scans a raw grayscale (Y800) image frame.
    /// Returns a `SymbolIterator` containing the scanned results.
    pub fn scanImage(self: *Scanner, width: u32, height: u32, gray_pixels: []const u8) Error!SymbolIterator {
        const img = c.zbar_image_create() orelse return error.ScanFailed;
        errdefer c.zbar_image_destroy(img);

        // Convert format tag 'Y800' (grayscale) to integer representation
        c.zbar_image_set_format(img, @as(c_ulong, @intCast(fourcc('Y', '8', '0', '0'))));
        c.zbar_image_set_size(img, @intCast(width), @intCast(height));
        c.zbar_image_set_data(img, gray_pixels.ptr, @intCast(gray_pixels.len), null);

        const n = c.zbar_scan_image(self.raw, img);
        if (n < 0) return error.ScanFailed;

        const first_symbol = c.zbar_image_first_symbol(img);
        return SymbolIterator{
            .img_to_cleanup = img,
            .current_symbol = first_symbol,
        };
    }
};

/// Represents a single decoded barcode/QR code result.
pub const Barcode = struct {
    /// Note: This slice borrows memory directly from the parent ZBar image frame.
    /// It remains valid only until the parent `SymbolIterator` is deinitialized.
    /// If you need to keep this data long-term, clone it using an allocator!
    data: []const u8,
    type_id: c_int,
};

/// Helper iterator to loop over all barcodes detected in a frame.
pub const SymbolIterator = struct {
    img_to_cleanup: *c.zbar_image_t,
    current_symbol: ?*const c.zbar_symbol_t,

    pub fn deinit(self: *SymbolIterator) void {
        // Frees the image and all associated symbols
        c.zbar_image_destroy(self.img_to_cleanup);
    }

    pub fn next(self: *SymbolIterator) ?Barcode {
        const sym = self.current_symbol orelse return null;
        defer self.current_symbol = c.zbar_symbol_next(sym);

        const data_ptr = c.zbar_symbol_get_data(sym);
        const len = c.zbar_symbol_get_data_length(sym);
        
        if (data_ptr != null and len > 0) {
            return Barcode{
                .data = data_ptr[0..len],
                .type_id = @intCast(c.zbar_symbol_get_type(sym)),
            };
        }
        return null;
    }
};

pub fn fourcc(a: u8, b: u8, c: u8, d: u8) u32 {
    return @as(u32, a) | (@as(u32, b) << 8) | (@as(u32, c) << 16) | (@as(u32, d) << 24);
}