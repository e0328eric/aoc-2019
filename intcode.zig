const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const c = std.c;

// Allocator and Deallocator with C API
pub fn alloc(comptime T: type, len: usize) ?[*]T {
    return @ptrCast([*]T, @alignCast(@alignOf(T), c.malloc(@sizeOf(T) * len) orelse return null));
}

pub fn free(comptime T: type, ptr: ?[*]T) void {
    c.free(ptr orelse return);
}

const Opcode = enum(u8) {
    Add = 1,
    Multiply,
    Halt = 99,
};

pub const Machine = struct {
    init_source: [*]i64,
    source: [*]i64,
    len: usize,
    pos: usize,
    is_halt: bool,

    pub fn machineFromString(string: []u8) !@This() {
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

        output.source = alloc(i64, source_len) orelse return error.AllocFailed;
        output.init_source = alloc(i64, source_len) orelse return error.AllocFailed;

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

    pub fn freeMachine(machine: *@This()) void {
        free(i64, machine.init_source);
        free(i64, machine.source);
    }

    pub fn dumpMachine(machine: *const @This()) void {
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

    pub fn resetMachine(machine: *@This()) void {
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

    pub fn runMachine(machine: *@This()) bool {
        while (!machine.is_halt) {
            if (!machine.runMachineOnce()) {
                return false;
            }
        }

        return true;
    }
};
