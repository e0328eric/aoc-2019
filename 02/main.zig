const std = @import("std");
const io = std.io;
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const c = std.c;

const Opcode = enum(u8) {
    Add = 1,
    Multiply,
    Halt = 99,
};

const Machine = struct {
    init_source: [*]i64,
    source: [*]i64,
    len: usize,
    pos: usize,
    is_halt: bool,

    fn machineFromString(string: []u8) !@This() {
        var output: @This() = .{
            .init_source = undefined,
            .source = undefined,
            .len = undefined,
            .pos = 0,
            .is_halt = false,
        };
        var source_len: usize = 1;
        for (string) |chr| {
            if (chr == ',') {
                source_len += 1;
            }
        }

        output.source = @ptrCast([*]i64, @alignCast(8, c.malloc(@sizeOf(i64) * source_len).?));
        output.init_source = @ptrCast([*]i64, @alignCast(8, c.malloc(@sizeOf(i64) * source_len).?));

        var idx: usize = 0;
        var start: usize = 0;
        for (string) |chr, i| {
            if (chr == 0) {
                break;
            }
            if (chr != ',' and chr != '\n') {
                continue;
            }

            output.source[idx] = try parseInt(i64, string[start..i], 10);
            idx += 1;
            start = i + 1;
        }

        mem.copy(i64, output.init_source[0..source_len], output.source[0..source_len]);
        output.len = source_len;

        return output;
    }

    fn freeMachine(machine: *@This()) void {
        c.free(machine.init_source);
        c.free(machine.source);
    }

    fn dumpMachine(machine: *const @This()) void {
        print("[ ", .{});

        var i: usize = 0;
        while (i < machine.len) : (i += 1) {
            if (i == machine.pos) {
                print("\x1b[30;107m{d}\x1b[0m ", .{machine.source[i]});
            } else {
                print("{d} ", .{machine.source[i]});
            }
        }

        print("]\n", .{});
    }

    fn resetMachine(machine: *@This()) void {
        mem.copy(i64, machine.source[0..machine.len], machine.init_source[0..machine.len]);
        machine.pos = 0;
        machine.is_halt = false;
    }

    fn runMachineOnce(machine: *@This()) bool {
        var store_pos: usize = undefined;
        var pos1: usize = undefined;
        var pos2: usize = undefined;

        switch (@intToEnum(Opcode, machine.source[machine.pos])) {
            .Add => {
                store_pos = @intCast(usize, machine.source[machine.pos + 3]);
                pos1 = @intCast(usize, machine.source[machine.pos + 1]);
                pos2 = @intCast(usize, machine.source[machine.pos + 2]);
                machine.source[store_pos] = machine.source[pos1] + machine.source[pos2];
                machine.pos += 4;
            },
            .Multiply => {
                store_pos = @intCast(usize, machine.source[machine.pos + 3]);
                pos1 = @intCast(usize, machine.source[machine.pos + 1]);
                pos2 = @intCast(usize, machine.source[machine.pos + 2]);
                machine.source[store_pos] = machine.source[pos1] * machine.source[pos2];
                machine.pos += 4;
            },
            .Halt => machine.is_halt = true,
        }

        return true;
    }

    fn runMachine(machine: *@This()) bool {
        while (!machine.is_halt) {
            if (!machine.runMachineOnce()) {
                return false;
            }
        }

        return true;
    }
};

fn solve1(source: []u8) !i64 {
    var machine = try Machine.machineFromString(source);
    defer machine.freeMachine();

    machine.source[1] = 12;
    machine.source[2] = 2;

    if (!machine.runMachine()) {
        return -1;
    }

    return machine.source[0];
}

fn solve2(source: []u8) !i64 {
    var machine = try Machine.machineFromString(source);
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

pub fn main() !void {
    var file = try fs.cwd().openFile("./input.txt", .{});
    defer file.close();

    var file_len = try file.getEndPos();
    var buffer = @ptrCast([*:0]u8, c.malloc(@sizeOf(u8) * (file_len + 1)).?);
    defer c.free(buffer);
    _ = try file.read(buffer[0..file_len]);

    print("Answer1: {}\n", .{try solve1(buffer[0..file_len])});
    print("Answer2: {}\n", .{try solve2(buffer[0..file_len])});
}
