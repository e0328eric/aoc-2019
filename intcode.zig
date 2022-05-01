const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const allocator = std.heap.raw_c_allocator;

const Opcode = enum(u8) {
    Add = 1,
    Multiply = 2,
    Input = 3,
    Output = 4,
    JmpIfT = 5,
    JmpIfF = 6,
    Less = 7,
    Eq = 8,
    Halt = 99,
};

const ParamMode = enum(u2) {
    Position,
    Immediate,
};

pub const ExitMode = enum(u2) {
    EmitOutput,
    UntilHalt,
};

fn parseOpcode(
    raw_opcode: i64,
    opcode_output: *Opcode,
    param_output: *[2]ParamMode,
) void {
    var fst_mode: u8 = @intCast(u8, @mod(@divFloor(raw_opcode, 100), 10));
    var snd_mode: u8 = @intCast(u8, @mod(@divFloor(raw_opcode, 1000), 10));
    var opcode: u8 = @intCast(u8, @mod(raw_opcode, 100));

    opcode_output.* = @intToEnum(Opcode, opcode);
    param_output[0] = @intToEnum(ParamMode, fst_mode);
    param_output[1] = @intToEnum(ParamMode, snd_mode);
}

const IO_CAPACITY = 100;
pub const Machine = struct {
    init_source: []i64,
    source: []i64,
    len: usize,
    pos: usize,
    inputs: [IO_CAPACITY]i64,
    input_len: usize,
    input_pos: usize,
    outputs: [IO_CAPACITY]i64,
    output_pos: usize,
    is_halt: bool,

    pub fn machineFromString(string: []const u8) !@This() {
        var output: @This() = .{
            .init_source = undefined,
            .source = undefined,
            .len = undefined,
            .pos = 0,
            .inputs = [_]i64{0} ** IO_CAPACITY,
            .input_len = 0,
            .input_pos = 0,
            .outputs = [_]i64{0} ** IO_CAPACITY,
            .output_pos = 0,
            .is_halt = false,
        };
        var source_len: usize = 1;
        for (string) |chr| {
            if (chr == ',') {
                source_len += 1;
            }
        }

        output.source = try allocator.alloc(i64, source_len);
        output.init_source = try allocator.alloc(i64, source_len);

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

        mem.copy(i64, output.init_source, output.source);
        output.len = source_len;

        return output;
    }

    pub fn freeMachine(machine: *@This()) void {
        allocator.free(machine.init_source);
        allocator.free(machine.source);
    }

    pub fn dumpMachine(machine: *const @This()) void {
        print("=====\n[ ", .{});

        var i: usize = 0;
        while (i < machine.len) : (i += 1) {
            if (i == machine.pos) {
                print("\x1b[30;107m{d}\x1b[0m ", .{machine.source[i]});
            } else {
                print("{d} ", .{machine.source[i]});
            }
        }

        print("]\n", .{});

        i = 0;
        print("Input: [ ", .{});
        while (i < machine.input_len) : (i += 1) {
            print("{d} ", .{machine.inputs[i]});
        }
        print("] (len: {}, pos: {})\n", .{ machine.input_len, machine.input_pos });

        i = 0;
        print("Output: [ ", .{});
        while (i < machine.output_pos) : (i += 1) {
            print("{d} ", .{machine.outputs[i]});
        }
        print("] (halt: {})\n", .{machine.is_halt});
    }

    pub fn resetMachine(machine: *@This()) void {
        mem.copy(i64, machine.source, machine.init_source);
        machine.pos = 0;
        mem.set(i64, machine.inputs[0..], 0);
        mem.set(i64, machine.outputs[0..], 0);
        machine.input_len = 0;
        machine.input_pos = 0;
        machine.output_pos = 0;
        machine.is_halt = false;
    }

    pub fn inputHandler(machine: *@This(), comptime InputType: type, input: InputType) !void {
        if (InputType == i64) {
            if (1 + machine.input_len >= IO_CAPACITY) {
                return error.InputOverflow;
            }
            machine.inputs[machine.input_len] = input;
            machine.input_len += 1;
        } else if (InputType == []i64) {
            if (input.len + machine.input_len >= IO_CAPACITY) {
                return error.InputOverflow;
            }
            mem.copy(i64, machine.inputs[machine.input_len..], input);
            machine.input_len += input.len;
        } else {
            return error.IllegalInpuyType;
        }
    }

    pub fn outputHandler(machine: *@This()) []i64 {
        return machine.outputs[0..machine.output_pos];
    }

    fn takeValue(machine: *const @This(), pos: usize, mode: ParamMode) i64 {
        return switch (mode) {
            .Position => machine.source[@intCast(usize, machine.source[machine.pos + pos])],
            .Immediate => machine.source[machine.pos + pos],
        };
    }

    fn runMachineOnce(machine: *@This(), comptime exit_mode: ExitMode) !bool {
        var store_pos: usize = undefined;
        var val1: i64 = undefined;
        var val2: i64 = undefined;
        var opcode: Opcode = undefined;
        var param_modes: [2]ParamMode = undefined;

        parseOpcode(machine.source[machine.pos], &opcode, &param_modes);

        switch (opcode) {
            .Add => {
                store_pos = @intCast(usize, machine.source[machine.pos + 3]);
                val1 = machine.takeValue(1, param_modes[0]);
                val2 = machine.takeValue(2, param_modes[1]);
                machine.source[store_pos] = val1 + val2;
                machine.pos += 4;
            },
            .Multiply => {
                store_pos = @intCast(usize, machine.source[machine.pos + 3]);
                val1 = machine.takeValue(1, param_modes[0]);
                val2 = machine.takeValue(2, param_modes[1]);
                machine.source[store_pos] = val1 * val2;
                machine.pos += 4;
            },
            .Input => {
                store_pos = @intCast(usize, machine.source[machine.pos + 1]);
                machine.source[store_pos] = machine.inputs[machine.input_pos];
                if (machine.input_pos < machine.input_len) {
                    machine.input_pos += 1;
                }
                machine.pos += 2;
            },
            .Output => {
                val1 = machine.takeValue(1, param_modes[0]);
                if (machine.output_pos >= IO_CAPACITY) {
                    return error.OutputOverflow;
                }
                machine.outputs[machine.output_pos] = val1;
                machine.output_pos += 1;
                machine.pos += 2;
                if (exit_mode == .EmitOutput) {
                    return true;
                }
            },
            .JmpIfT => {
                val1 = machine.takeValue(1, param_modes[0]);
                val2 = machine.takeValue(2, param_modes[1]);
                if (val1 != 0) {
                    machine.pos = @intCast(usize, val2);
                } else {
                    machine.pos += 3;
                }
            },
            .JmpIfF => {
                val1 = machine.takeValue(1, param_modes[0]);
                val2 = machine.takeValue(2, param_modes[1]);
                if (val1 == 0) {
                    machine.pos = @intCast(usize, val2);
                } else {
                    machine.pos += 3;
                }
            },
            .Less => {
                store_pos = @intCast(usize, machine.source[machine.pos + 3]);
                val1 = machine.takeValue(1, param_modes[0]);
                val2 = machine.takeValue(2, param_modes[1]);
                machine.source[store_pos] = if (val1 < val2) 1 else 0;
                machine.pos += 4;
            },
            .Eq => {
                store_pos = @intCast(usize, machine.source[machine.pos + 3]);
                val1 = machine.takeValue(1, param_modes[0]);
                val2 = machine.takeValue(2, param_modes[1]);
                machine.source[store_pos] = if (val1 == val2) 1 else 0;
                machine.pos += 4;
            },
            .Halt => {
                machine.is_halt = true;
                return true;
            },
        }

        return false;
    }

    pub fn runMachine(machine: *@This(), comptime exit_mode: ExitMode) !void {
        var is_halt: bool = false;
        while (!machine.is_halt and !is_halt) {
            is_halt = try machine.runMachineOnce(exit_mode);
        }
    }
};
