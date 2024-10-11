const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("uw8", .{
        .root_source_file = b.path("src/uw8.zig"),
    });
}
