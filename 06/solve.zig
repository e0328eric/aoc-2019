const std = @import("std");
const io = std.io;
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;
const expect = std.testing.expect;
const allocator = std.heap.raw_c_allocator;

const Node = struct {
    name: []const u8,
    prev: ?*Node,

    fn init(name: []const u8) @This() {
        return .{ .name = name, .prev = null };
    }
};

const orbit_tree_capacity = 2048;
const OrbitTree = struct {
    container: []?Node,
    pos: usize,
    finder: std.StringHashMap(usize),

    fn init() !@This() {
        var container = try allocator.alloc(?Node, orbit_tree_capacity);
        return @This(){ .container = container, .pos = 0, .finder = std.StringHashMap(usize).init(allocator) };
    }

    fn deinit(self: *@This()) void {
        allocator.free(self.container);
        self.finder.deinit();
    }

    fn put(self: *@This(), orbitor: []const u8, orbitee: []const u8) !void {
        const orbitor_loc = self.finder.get(orbitor) orelse blk: {
            if (self.pos >= orbit_tree_capacity) {
                return error.OrbitOverflow;
            }
            self.container[self.pos] = Node.init(orbitor);
            self.pos += 1;
            try self.finder.put(orbitor, self.pos - 1);
            break :blk self.pos - 1;
        };
        const orbitee_loc = self.finder.get(orbitee) orelse blk: {
            if (self.pos >= orbit_tree_capacity) {
                return error.OrbitOverflow;
            }
            self.container[self.pos] = Node.init(orbitee);
            self.pos += 1;
            try self.finder.put(orbitee, self.pos - 1);
            break :blk self.pos - 1;
        };

        var orbitee_node = &self.container[orbitee_loc].?;
        orbitee_node.prev = &self.container[orbitor_loc].?;
    }
};

fn count_orbit_num(node: *const Node) i32 {
    if (node.prev == null and true) {
        return 0;
    }

    var answer: i32 = 0;
    answer += count_orbit_num(node.prev.?) + 1;

    return answer;
}

fn collectOrbitors(node: *const Node, output: [][]const u8, pos: *usize) anyerror!void {
    if (pos.* >= 1024) {
        return error.CollectTooManyOrbits;
    }

    if (node.prev == null and true) {
        output[pos.*] = node.name;
        pos.* += 1;
        return;
    }

    try collectOrbitors(node.prev.?, output, pos);
    output[pos.*] = node.name;
    pos.* += 1;
}

fn findCommon(
    you_orbits: [][]const u8,
    santa_orbits: [][]const u8,
    you_len: usize,
    santa_len: usize,
) i32 {
    var i: i32 = @intCast(i32, you_len);
    var j: i32 = @intCast(i32, santa_len);

    while (j > 0) : ({
        i -= 1;
        if (i == 0) {
            j -= 1;
            i = @intCast(i32, you_len);
        }
    }) {
        if (mem.eql(u8, you_orbits[@intCast(usize, i - 1)], santa_orbits[@intCast(usize, j - 1)])) {
            break;
        }
    }

    return @intCast(i32, you_len + santa_len) - i - j - 2;
}

fn solve1(source: []const u8) !i32 {
    var main_iter = mem.split(u8, source, "\n");

    var orbit = try OrbitTree.init();
    defer orbit.deinit();

    var iter: mem.SplitIterator(u8) = undefined;
    var orbitor: []const u8 = undefined;
    var orbitee: []const u8 = undefined;
    while (main_iter.next()) |line| {
        iter = mem.split(u8, line, ")");
        orbitor = iter.next() orelse break;
        orbitee = iter.next() orelse break;
        try orbit.put(orbitor, orbitee);
    }

    var answer: i32 = 0;
    for (orbit.container) |node| {
        answer += count_orbit_num(&(node orelse break));
    }

    return answer;
}

fn solve2(source: []const u8) !i32 {
    var main_iter = mem.split(u8, source, "\n");

    var orbit = try OrbitTree.init();
    defer orbit.deinit();

    var iter: mem.SplitIterator(u8) = undefined;
    var orbitor: []const u8 = undefined;
    var orbitee: []const u8 = undefined;
    while (main_iter.next()) |line| {
        iter = mem.split(u8, line, ")");
        orbitor = iter.next() orelse break;
        orbitee = iter.next() orelse break;
        try orbit.put(orbitor, orbitee);
    }

    var you_orbits = try allocator.alloc([]const u8, 1024);
    defer allocator.free(you_orbits);
    var santa_orbits = try allocator.alloc([]const u8, 1024);
    defer allocator.free(santa_orbits);

    var you_pos: usize = 0;
    var santa_pos: usize = 0;
    var you_node = orbit.container[orbit.finder.get("YOU").?].?;
    var santa_node = orbit.container[orbit.finder.get("SAN").?].?;
    try collectOrbitors(&you_node, you_orbits, &you_pos);
    try collectOrbitors(&santa_node, santa_orbits, &santa_pos);

    return findCommon(you_orbits, santa_orbits, you_pos, santa_pos);
}

pub fn printAnswer() !void {
    const source = @embedFile("./input.txt");

    print("Answer1: {}\n", .{try solve1(source)});
    print("Answer2: {}\n", .{try solve2(source)});
}
