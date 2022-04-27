const std = @import("std");
const math = std.math;
const print = std.debug.print;
const expect = std.testing.expect;

const start: u32 = 240920;
const end: u32 = 789857;

fn fillDigits(digits: *[6]u8, number: u32) !void {
    var i: i32 = 5;
    var powed: u32 = undefined;
    while (i >= 0) : (i -= 1) {
        powed = try math.powi(u32, 10, @intCast(u32, i));
        digits[@intCast(usize, 5 - i)] = @intCast(u8, @mod(@divFloor(number, powed), 10));
    }
}

fn solve1() !i32 {
    var digits: [6]u8 = undefined;
    var i: u32 = start;
    var j: usize = undefined;
    var is_exist_same: bool = undefined;
    var answer: i32 = 0;

    mainLoop: while (i <= end) : (i += 1) {
        try fillDigits(&digits, i);

        j = 0;
        is_exist_same = false;
        while (j < 5) : (j += 1) {
            if (digits[j] > digits[j + 1]) {
                continue :mainLoop;
            }
            if (digits[j] == digits[j + 1]) {
                is_exist_same = true;
            }
        }

        if (!is_exist_same) {
            continue;
        }

        answer += 1;
    }

    return answer;
}

fn solve2() !i32 {
    var digits: [6]u8 = undefined;
    var i: u32 = start;
    var j: usize = undefined;
    var is_exist_same: bool = undefined;
    var count_num: u32 = undefined;
    var answer: i32 = 0;

    mainLoop: while (i <= end) : (i += 1) {
        try fillDigits(&digits, i);

        j = 0;
        is_exist_same = false;
        count_num = 0;
        while (j < 5) : (j += 1) {
            if (digits[j] > digits[j + 1]) {
                continue :mainLoop;
            }
            if (digits[j] == digits[j + 1]) {
                count_num += 1;
            }
            if (j == 4 or digits[j] != digits[j + 1]) {
                if (!is_exist_same and count_num == 1) {
                    is_exist_same = true;
                }
                count_num = 0;
            }
        }

        if (!is_exist_same) {
            continue;
        }

        answer += 1;
    }

    return answer;
}

pub fn printAnswer() !void {
    print("Answer1: {}\n", .{try solve1()});
    print("Answer2: {}\n", .{try solve2()});
}
