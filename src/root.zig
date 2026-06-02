//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

pub const ndarray =
    @import("ndarray/ndarray.zig");

pub const dataframe =
    @import("dataframe/dataframe.zig");

pub const sql =
    @import("sql/table.zig");

pub const db =
    @import("db/database.zig");

pub const plot =
    @import("plot/canvas.zig");

pub const scizig =
    @import("scizig/optimize.zig");

pub const ai =
    @import("ai/linear_regression.zig");

/// This is a documentation comment to explain the `printAnotherMessage` function below.
///
/// Accepting an `Io.Writer` instance is a handy way to write reusable code.
pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("Run `zig build test` to run the tests.\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
