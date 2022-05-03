const std = @import("std");
const print = std.debug.print;

const pixel_width: usize = 25;
const pixel_tall: usize = 6;

const ChunkIter = struct {
    buffer: []const u8,
    index: usize,

    const Self = @This();

    fn new(source: []const u8) Self {
        return .{ .buffer = source, .index = 0 };
    }

    fn next(self: *Self) ?[]const u8 {
        const start = self.index;
        if (start >= self.buffer.len) {
            return null;
        }

        self.index += pixel_width * pixel_tall;
        const end = if (self.index >= self.buffer.len) blk: {
            break :blk self.buffer.len;
        } else blk: {
            break :blk self.index;
        };

        return self.buffer[start..end];
    }
};

fn print_chunk(source: []const u8) void {
    var iter = ChunkIter.new(source);

    while (iter.next()) |pixels| {
        for (pixels) |pixel, j| {
            print("{c}", .{pixel});
            if ((j + 1) % pixel_width == 0) {
                print("\n", .{});
            }
        }
        print("\n", .{});
    }
}

fn solve1(source: []const u8) i64 {
    var iter = ChunkIter.new(source[0 .. source.len - 1]);
    var count_digits = [3]usize{ 0, 0, 0 };
    var answer = [3]usize{ 0, 0, 0 };
    var minimum_zero: usize = std.math.maxInt(usize);

    while (iter.next()) |pixels| {
        count_digits = [_]usize{ 0, 0, 0 };
        for (pixels) |pixel| {
            switch (pixel) {
                '0' => count_digits[0] += 1,
                '1' => count_digits[1] += 1,
                '2' => count_digits[2] += 1,
                else => unreachable,
            }
        }
        minimum_zero = if (count_digits[0] <= minimum_zero) blk: {
            answer[1] = count_digits[1];
            answer[2] = count_digits[2];
            break :blk count_digits[0];
        } else blk: {
            break :blk minimum_zero;
        };
    }

    return @intCast(i64, answer[1] * answer[2]);
}

fn solve2(source: []const u8) void {
    // to remove the newline
    var iter = ChunkIter.new(source[0 .. source.len - 1]);
    var image = [_]u8{'2'} ** (pixel_width * pixel_tall);

    while (iter.next()) |pixels| {
        for (pixels) |pixel, i| {
            if (image[i] == '2') {
                image[i] = pixel;
            }
        }
    }

    for (image) |pixel, i| {
        switch (pixel) {
            '0' => print("\x1b[40m  ", .{}),
            '1' => print("\x1b[47m  ", .{}),
            else => unreachable,
        }
        if ((i + 1) % pixel_width == 0) {
            print("\x1b[0m\n", .{});
        }
    }
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{solve1(source)});
    print("Answer2:\n", .{});
    solve2(source);
}
