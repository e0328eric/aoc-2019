const std = @import("std");
const io = std.io;
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;
const expect = std.testing.expect;
const allocator = std.heap.raw_c_allocator;

fn solve1(source: []const u8) !i32 {
    _ = source;
    return 0;
}
fn solve2(source: []const u8) !i32 {
    _ = source;
    return 0;
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{try solve1(source)});
    print("Answer2: {}\n", .{try solve2(source)});
}
