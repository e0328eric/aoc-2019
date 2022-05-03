const std = @import("std");
const day1 = @import("01/solve.zig");
const day2 = @import("02/solve.zig");
const day3 = @import("03/solve.zig");
const day4 = @import("04/solve.zig");
const day5 = @import("05/solve.zig");
const day6 = @import("06/solve.zig");
const day7 = @import("07/solve.zig");
const day8 = @import("08/solve.zig");
const day9 = @import("09/solve.zig");
const print = std.debug.print;

pub fn main() !void {
    print("====== Day 1 ======\n\n", .{});
    try day1.printAnswer();
    print("\n====== Day 2 ======\n\n", .{});
    try day2.printAnswer();
    print("\n====== Day 3 ======\n\n", .{});
    try day3.printAnswer();
    print("\n====== Day 4 ======\n\n", .{});
    try day4.printAnswer();
    print("\n====== Day 5 ======\n\n", .{});
    try day5.printAnswer();
    print("\n====== Day 6 ======\n\n", .{});
    try day6.printAnswer();
    print("\n====== Day 7 ======\n\n", .{});
    try day7.printAnswer();
    print("\n====== Day 8 ======\n\n", .{});
    try day8.printAnswer();
    print("\n====== Day 9 ======\n\n", .{});
    try day9.printAnswer();
}
