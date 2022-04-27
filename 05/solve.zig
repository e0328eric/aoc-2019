const std = @import("std");
const io = std.io;
const fs = std.fs;
const intcode = @import("../intcode.zig");
const print = std.debug.print;
const allocator = std.heap.page_allocator;
const expect = std.testing.expect;

fn solve1(source: []u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    var inputs = [_]i64{1};
    try machine.inputHandler(inputs[0..]);
    try machine.runMachine();
    var outputs = try machine.outputHandler();
    defer allocator.free(outputs);

    return outputs[outputs.len - 1];
}

fn solve2(source: []u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    var inputs = [_]i64{5};
    try machine.inputHandler(inputs[0..]);
    try machine.runMachine();
    var outputs = try machine.outputHandler();
    defer allocator.free(outputs);

    return outputs[outputs.len - 1];
}

pub fn printAnswer() !void {
    var file = try fs.cwd().openFile("./05/input.txt", .{});
    defer file.close();

    var file_len = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_len + 1);
    defer allocator.free(buffer);
    _ = try file.read(buffer[0..file_len]);

    print("Answer1: {}\n", .{try solve1(buffer[0..file_len])});
    print("Answer2: {}\n", .{try solve2(buffer[0..file_len])});
}
