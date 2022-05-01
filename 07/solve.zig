const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;
const intcode = @import("../intcode.zig");
const allocator = std.heap.raw_c_allocator;

fn powi(base: u64, exp: u64) i64 {
    var i: u64 = 0;
    var output: u64 = base;
    while (i < exp) : (i += 1) {
        output *|= base;
    }
    return @intCast(i64, output);
}
const phase_bound: i64 =
    4 * powi(5, 4) + 3 * powi(5, 3) + 2 * powi(5, 2) + 1 * powi(5, 1);
fn convertPhase(comptime offset: i64, num: i64, phase: *[5]i64) !void {
    if (num > phase_bound) {
        return error.PhaseOverflow;
    }

    var i: u64 = 0;
    while (i < 5) : (i += 1) {
        phase[@intCast(usize, i)] = @mod(@divFloor(num, powi(5, 4 - i)), 5) + offset;
    }
}

fn isAllDifferent(phase: *const [5]i64) bool {
    var i: usize = 0;
    var j: usize = 1;

    while (i < 5) : (i += 1) {
        j = i + 1;
        while (j < 5) : (j += 1) {
            if (phase[i] == phase[j]) {
                return false;
            }
        }
    }

    return true;
}

fn solve1(source: []const u8) !i64 {
    var phase_setting: [5]i64 = undefined;
    var machine = try intcode.Machine.machineFromString(source);
    defer machine.freeMachine();

    var output: i64 = 0;
    var answer: i64 = std.math.minInt(i64);
    var i: i64 = 0;
    while (i <= phase_bound) : (i += 1) {
        try convertPhase(0, i, &phase_setting);
        if (!isAllDifferent(&phase_setting)) continue;

        output = 0;
        for (phase_setting) |phase| {
            machine.resetMachine();
            try machine.inputHandler(i64, phase);
            try machine.inputHandler(i64, output);
            try machine.runMachine(intcode.ExitMode.UntilHalt);

            output = machine.outputHandler()[0];
        }

        answer = if (output >= answer) output else answer;
    }

    return answer;
}

fn isAnyHalt(machines: *const [5]?intcode.Machine) bool {
    for (machines.*) |*machine| {
        if (machine.*.?.is_halt) {
            return true;
        }
    }

    return false;
}

fn solve2(source: []const u8) !i64 {
    var phase_setting: [5]i64 = undefined;
    var machines = [_]?intcode.Machine{null} ** 5;
    defer for (machines) |*machine| {
        if (machine.* != null) machine.*.?.freeMachine();
    };
    for (machines) |*machine| {
        machine.* = try intcode.Machine.machineFromString(source);
    }

    var output: i64 = 0;
    var outputs: []i64 = undefined;
    var answer: i64 = std.math.minInt(i64);
    var i: i64 = 0;
    while (i <= phase_bound) : (i += 1) {
        try convertPhase(5, i, &phase_setting);
        if (!isAllDifferent(&phase_setting)) continue;

        output = 0;
        for (phase_setting) |phase, n| {
            machines[n].?.resetMachine();
            try machines[n].?.inputHandler(i64, phase);
        }
        while (!isAnyHalt(&machines)) {
            for (machines) |*machine| {
                try machine.*.?.inputHandler(i64, output);
                try machine.*.?.runMachine(intcode.ExitMode.EmitOutput);

                outputs = machine.*.?.outputHandler();
                output = outputs[outputs.len - 1];
            }
        }

        answer = if (output >= answer) output else answer;
    }

    return answer;
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{try solve1(source)});
    print("Answer2: {}\n", .{try solve2(source)});
}
