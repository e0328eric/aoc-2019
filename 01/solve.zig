const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const io = std.io;
const parseInt = std.fmt.parseInt;

fn solve1(fuel: i32) i32 {
    return @divFloor(fuel, 3) - 2;
}

fn solve2(fuel: i32) i32 {
    var init_fuel = fuel;
    var output: i32 = 0;

    while (init_fuel > 0) {
        init_fuel = @divFloor(init_fuel, 3) - 2;
        init_fuel = @boolToInt(init_fuel > 0) * init_fuel;
        output += init_fuel;
    }

    return output;
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");
    var iter = std.mem.tokenize(u8, source, "\n");

    var parsed: i32 = undefined;
    var answer1: i32 = 0;
    var answer2: i32 = 0;
    while (iter.next()) |line| {
        parsed = try parseInt(i32, line, 10);
        answer1 += solve1(parsed);
        answer2 += solve2(parsed);
    }

    print("Answer1: {}\n", .{answer1});
    print("Answer2: {}\n", .{answer2});
}
