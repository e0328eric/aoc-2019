const std = @import("std");
const io = std.io;
const fs = std.fs;
const print = std.debug.print;
const intcode = @import("../intcode.zig");

fn solve1(source: []u8) !i64 {
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    machine.source[1] = 12;
    machine.source[2] = 2;

    if (!machine.runMachine()) {
        return -1;
    }

    return machine.source[0];
}

fn solve2(source: []u8) !i64 {
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

        if (!machine.runMachine()) {
            return -1;
        }

        if (machine.source[0] == 19690720) {
            return 100 * noun + verb;
        }
    }

    return -2;
}

pub fn printAnswer() !void {
    var file = try fs.cwd().openFile("./02/input.txt", .{});
    defer file.close();

    var file_len = try file.getEndPos();
    var buffer = intcode.alloc(u8, file_len + 1).?;
    defer intcode.free(u8, buffer);
    _ = try file.read(buffer[0..file_len]);

    print("Answer1: {}\n", .{try solve1(buffer[0..file_len])});
    print("Answer2: {}\n", .{try solve2(buffer[0..file_len])});
}
