const std = @import("std");
const io = std.io;
const fs = std.fs;
const intcode = @import("../intcode.zig");
const print = std.debug.print;
const allocator = std.heap.raw_c_allocator;
const expect = std.testing.expect;

fn solve1(source: []const u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    try machine.inputHandler(i64, 1);
    try machine.runMachine(intcode.ExitMode.UntilHalt);
    var outputs = machine.outputHandler();

    return outputs[outputs.len - 1];
}

fn solve2(source: []const u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    try machine.inputHandler(i64, 5);
    try machine.runMachine(intcode.ExitMode.UntilHalt);
    var outputs = machine.outputHandler();

    return outputs[outputs.len - 1];
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{try solve1(source[0..])});
    print("Answer2: {}\n", .{try solve2(source[0..])});
}
