const MakiStack = @import("root.zig");

//use stable zig version 0.14
// /usr/bin/zig run main.zig

const std = @import("std");

pub fn main() !void {
    MakiStack.ndarray.hello_ndarray();
    MakiStack.dataframe.hello_dataframe();
    MakiStack.sql.hello_sql();
    MakiStack.plot.hello_canvas();
    MakiStack.ai.hello_linear_regression();
    MakiStack.db.hello_database();
    MakiStack.scizig.hello_optimize();

    var gpa =
        std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator =
        gpa.allocator();

    var df =
        MakiStack.dataframe.DataFrame.init(
            allocator,
        );

    defer df.deinit();

    const ids = [_]i64{
        1, 2, 3,
    };

    const salaries = [_]f64{
        5000,
        7200,
        9100,
    };

    const names = [_][]const u8{
        "Joao",
        "Maria",
        "Ana",
    };

    try df.addIntColumn(
        "id",
        &ids,
    );

    try df.addFloatColumn(
        "salary",
        &salaries,
    );

    try df.addStringColumn(
        "name",
        &names,
    );

    df.info();

    std.debug.print(
        "\nHEAD\n",
        .{},
    );

    df.head(3);

    const avg =
        try df.mean(
            "salary",
        );

    std.debug.print(
        "\nMean Salary = {d:.2}\n",
        .{avg},
    );
}
