const std = @import("std");
const intcode = @import("../intcode.zig");
const print = std.debug.print;

fn solve1(source: []const u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    try machine.inputHandler(i64, 1);
    try machine.runMachine(intcode.ExitMode.UntilHalt);
    return machine.outputHandler()[0];
}

fn solve2(source: []const u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    try machine.inputHandler(i64, 2);
    try machine.runMachine(intcode.ExitMode.UntilHalt);
    return machine.outputHandler()[0];
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{try solve1(source)});
    print("Answer2: {}\n", .{try solve2(source)});
}
