const std = @import("std");
const io = std.io;
const fs = std.fs;
const print = std.debug.print;
const intcode = @import("../intcode.zig");
const allocator = std.heap.raw_c_allocator;

fn solve1(source: []const u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    machine.source[1] = 12;
    machine.source[2] = 2;

    try machine.runMachine(intcode.ExitMode.UntilHalt);

    return machine.source[0];
}

fn solve2(source: []const u8) !i64 {
    const expect_value: i64 = 19690720;
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    var noun: i64 = 0;
    var verb: i64 = 0;

    while (verb < 100) : ({
        noun += 1;
        if (noun >= 100) {
            verb += 1;
            noun = 0;
        }
    }) {
        machine.resetMachine();
        machine.source[1] = noun;
        machine.source[2] = verb;

        try machine.runMachine(intcode.ExitMode.UntilHalt);

        if (machine.source[0] == expect_value) {
            return 100 * noun + verb;
        }
    }

    return -1;
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{try solve1(source[0..])});
    print("Answer2: {}\n", .{try solve2(source[0..])});
}
