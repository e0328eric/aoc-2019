const std = @import("std");
const day1 = @import("01/solve.zig");
const day2 = @import("02/solve.zig");
const day3 = @import("03/solve.zig");
const print = std.debug.print;

pub fn main() !void {
    print("===== Day 1 =====\n\n", .{});
    try day1.printAnswer();
    print("\n===== Day 2 =====\n\n", .{});
    try day2.printAnswer();
    print("\n===== Day 3 =====\n\n", .{});
    try day3.printAnswer();
}
