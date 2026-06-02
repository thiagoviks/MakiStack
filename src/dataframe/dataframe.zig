const std = @import("std");

pub fn hello_dataframe() void {
    std.debug.print("MakiStack.dataframe loaded\n", .{});
}

pub const ColumnType = enum {
    integer,
    float,
    string,
};

pub const ColumnData = union(ColumnType) {
    integer: []i64,
    float: []f64,
    string: [][]const u8,
};

pub const Column = struct {
    name: []const u8,
    data: ColumnData,
};

pub const DataFrame = struct {
    allocator: std.mem.Allocator,
    columns: std.ArrayList(Column),
    rows: usize,

    pub fn init(
        allocator: std.mem.Allocator,
    ) DataFrame {
        return .{
            .allocator = allocator,
            .columns = std.ArrayList(Column).init(allocator),
            .rows = 0,
        };
    }

    pub fn deinit(
        self: *DataFrame,
    ) void {
        for (self.columns.items) |col| {
            switch (col.data) {
                .integer => |v| self.allocator.free(v),

                .float => |v| self.allocator.free(v),

                .string => |v| {
                    for (v) |s| {
                        self.allocator.free(s);
                    }
                    self.allocator.free(v);
                },
            }

            self.allocator.free(col.name);
        }

        self.columns.deinit();
    }

    pub fn addIntColumn(
        self: *DataFrame,
        name: []const u8,
        values: []const i64,
    ) !void {
        const copy_name =
            try self.allocator.dupe(u8, name);

        const data =
            try self.allocator.dupe(i64, values);

        try self.columns.append(.{
            .name = copy_name,
            .data = .{
                .integer = data,
            },
        });

        self.rows = data.len;
    }

    pub fn addFloatColumn(
        self: *DataFrame,
        name: []const u8,
        values: []const f64,
    ) !void {
        const copy_name =
            try self.allocator.dupe(u8, name);

        const data =
            try self.allocator.dupe(f64, values);

        try self.columns.append(.{
            .name = copy_name,
            .data = .{
                .float = data,
            },
        });

        self.rows = data.len;
    }

    pub fn addStringColumn(
        self: *DataFrame,
        name: []const u8,
        values: []const []const u8,
    ) !void {
        const copy_name =
            try self.allocator.dupe(u8, name);

        var data =
            try self.allocator.alloc(
                []const u8,
                values.len,
            );

        for (values, 0..) |s, i| {
            data[i] =
                try self.allocator.dupe(
                    u8,
                    s,
                );
        }

        try self.columns.append(.{
            .name = copy_name,
            .data = .{
                .string = data,
            },
        });

        self.rows = data.len;
    }

    pub fn info(
        self: *const DataFrame,
    ) void {
        std.debug.print(
            "Rows: {}\nColumns: {}\n\n",
            .{
                self.rows,
                self.columns.items.len,
            },
        );

        for (self.columns.items) |col| {
            switch (col.data) {
                .integer => |v| std.debug.print(
                    "{s}: int [{}]\n",
                    .{
                        col.name,
                        v.len,
                    },
                ),

                .float => |v| std.debug.print(
                    "{s}: float [{}]\n",
                    .{
                        col.name,
                        v.len,
                    },
                ),

                .string => |v| std.debug.print(
                    "{s}: string [{}]\n",
                    .{
                        col.name,
                        v.len,
                    },
                ),
            }
        }
    }

    pub fn head(
        self: *const DataFrame,
        n: usize,
    ) void {
        const limit =
            @min(
                n,
                self.rows,
            );

        for (0..limit) |row| {
            for (self.columns.items) |col| {
                switch (col.data) {
                    .integer => |v| std.debug.print(
                        "{}\t",
                        .{v[row]},
                    ),

                    .float => |v| std.debug.print(
                        "{d:.2}\t",
                        .{v[row]},
                    ),

                    .string => |v| std.debug.print(
                        "{s}\t",
                        .{v[row]},
                    ),
                }
            }

            std.debug.print(
                "\n",
                .{},
            );
        }
    }

    pub fn mean(
        self: *const DataFrame,
        column_name: []const u8,
    ) !f64 {
        for (self.columns.items) |col| {
            if (std.mem.eql(
                u8,
                col.name,
                column_name,
            )) {
                return switch (col.data) {
                    .float => |values| blk: {
                        var sum: f64 = 0;

                        for (values) |v| {
                            sum += v;
                        }

                        break :blk sum /
                            @as(
                                f64,
                                @floatFromInt(
                                    values.len,
                                ),
                            );
                    },

                    .integer => |values| blk: {
                        var sum: i64 = 0;

                        for (values) |v| {
                            sum += v;
                        }

                        break :blk @as(
                            f64,
                            @floatFromInt(
                                sum,
                            ),
                        ) /
                            @as(
                                f64,
                                @floatFromInt(
                                    values.len,
                                ),
                            );
                    },

                    else => error.NotNumeric,
                };
            }
        }

        return error.ColumnNotFound;
    }
};
