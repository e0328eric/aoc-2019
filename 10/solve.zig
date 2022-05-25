const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.raw_c_allocator;

fn Pair(comptime T: type, comptime U: type) type {
    return struct {
        fst: T,
        snd: U,

        const Self = @This();

        fn init(fst: T, snd: U) Self {
            return .{ .fst = fst, .snd = snd };
        }
    };
}

const Point = Pair(usize, usize);

fn get_dimension(source: []const u8) Point {
    var column: usize = 0;
    var row: usize = 0;
    var read_first_row: bool = false;
    for (source) |chr| {
        if (chr == '\n') {
            row += 1;
            read_first_row = true;
        } else if (!read_first_row) {
            column += 1;
        }
    }
    
    return Pair(usize,usize).init(row, column);
}

fn solve1(source: []const u8) !i64 {
    var row_col = get_dimension(source); // (row, col)

    var asteroids = try allocator.alloc([]Point, row_col.fst);
    defer allocator.free(asteroids);

    for (asteroids) |ast_row| {
        ast_row = try allocator.alloc(Point, row_col.snd);
        defer allocator.free(ast_row);
    }

    var iter = std.mem.tokenize(source, "\n");
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");
    _ = source;
}
