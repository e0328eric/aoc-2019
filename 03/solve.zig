const std = @import("std");
const io = std.io;
const fs = std.fs;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const math = std.math;
const allocator = std.heap.page_allocator;

// Define Types
const SegmentType = enum {
    Horizontal,
    Vertical,
};

const Segment = struct {
    seg_type: SegmentType,
    base_pos: i32,
    start: i32,
    end: i32,
};

const SegmentArray = struct {
    inner: ?[]Segment,
    len: usize,

    fn pathToSegments(path: *const Path) ?@This() {
        var output: @This() = undefined;

        output.len = path.len - 1;

        var ptr = allocator.alloc(Segment, output.len) catch return null;
        const inner = path.inner orelse return null;
        var i: usize = 0;
        while (i < output.len) : (i += 1) {
            if (inner[i].x == inner[i + 1].x) {
                ptr[i].seg_type = .Vertical;
                ptr[i].base_pos = inner[i].x;
                ptr[i].start = inner[i].y;
                ptr[i].end = inner[i + 1].y;
            } else if (inner[i].y == inner[i + 1].y) {
                ptr[i].seg_type = .Horizontal;
                ptr[i].base_pos = inner[i].y;
                ptr[i].start = inner[i].x;
                ptr[i].end = inner[i + 1].x;
            }
        }

        output.inner = ptr;
        return output;
    }

    fn freeSegArray(seg: *@This()) void {
        allocator.free(seg.inner orelse return);
        seg.inner = null;
        seg.len = 0;
    }
};

const Point = struct {
    x: i32,
    y: i32,
};

const Path = struct {
    inner: ?[]Point,
    len: usize,

    fn freePath(path: *@This()) void {
        allocator.free(path.inner orelse return);
        path.inner = null;
        path.len = 0;
    }
};

const Direction = enum(u8) {
    Up = 'U',
    Down = 'D',
    Left = 'L',
    Right = 'R',
};

fn parseInput(input: []u8) !Path {
    var output: Path = undefined;

    var len: usize = 1;
    for (input) |chr| {
        if (chr == ',') {
            len += 1;
        }
    }

    output.len = len + 1;
    output.inner = try allocator.alloc(Point, len + 1);

    output.inner.?[0].x = 0;
    output.inner.?[0].y = 0;

    var dir: Direction = undefined;
    var offset: i32 = undefined;
    var i: usize = 1;
    var start: usize = 0;
    var end: usize = 0;
    while (i <= len) : (i += 1) {
        dir = @intToEnum(Direction, input[end]);
        end += 1;
        start += 1;

        while (end < input.len and input[end] != ',') {
            end += 1;
        }
        offset = try parseInt(i32, input[start..end], 10);

        switch (dir) {
            .Up => {
                output.inner.?[i].x = output.inner.?[i - 1].x;
                output.inner.?[i].y = output.inner.?[i - 1].y + offset;
            },
            .Down => {
                output.inner.?[i].x = output.inner.?[i - 1].x;
                output.inner.?[i].y = output.inner.?[i - 1].y - offset;
            },
            .Left => {
                output.inner.?[i].x = output.inner.?[i - 1].x - offset;
                output.inner.?[i].y = output.inner.?[i - 1].y;
            },
            .Right => {
                output.inner.?[i].x = output.inner.?[i - 1].x + offset;
                output.inner.?[i].y = output.inner.?[i - 1].y;
            },
        }

        end += 1;
        start = end;
    }

    return output;
}

fn maxPos(seg: Segment) i32 {
    return math.max(seg.start, seg.end);
}

fn minPos(seg: Segment) i32 {
    return math.min(seg.start, seg.end);
}

fn solve1(seg1: *const SegmentArray, seg2: *const SegmentArray) i32 {
    var container: Path = undefined;
    var answer: i32 = math.maxInt(i32);

    container.inner = allocator.alloc(Point, seg1.len * 2) catch return -1;
    container.len = 0;
    defer container.freePath();

    var i: usize = 0;
    var j: usize = 0;
    var seg1_inner = seg1.inner orelse return -1;
    var seg2_inner = seg2.inner orelse return -1;
    while (i < seg1.len) : (i += 1) {
        while (j < seg2.len) : (j += 1) {
            if (seg1_inner[i].seg_type == seg2_inner[j].seg_type) {
                continue;
            }
            if (seg1_inner[i].base_pos == 0 and seg2_inner[j].base_pos == 0) {
                continue;
            }

            if ((seg1_inner[i].base_pos >= minPos(seg2_inner[j]) and seg1_inner[i].base_pos <= maxPos(seg2_inner[j])) and
                (seg2_inner[j].base_pos >= minPos(seg1_inner[i]) and seg2_inner[j].base_pos <= maxPos(seg1_inner[i])))
            {
                container.inner.?[container.len] = Point{ .x = seg1_inner[i].base_pos, .y = seg2_inner[j].base_pos };
                container.len += 1;
            }
        }
    }

    var tmp: i32 = 0;
    i = 0;
    while (i < container.len) : (i += 1) {
        tmp = (math.absInt(container.inner.?[i].x) catch return -1) + (math.absInt(container.inner.?[i].y) catch return -1);
        answer = if (tmp <= answer) tmp else answer;
    }

    return answer;
}

fn solve2(seg1: *const SegmentArray, seg2: *const SegmentArray) i32 {
    var tmp: i32 = undefined;
    var answer: i32 = math.maxInt(i32);

    var i: usize = 0;
    var j: usize = 0;
    var k: usize = undefined;
    var seg1_inner = seg1.inner orelse return -1;
    var seg2_inner = seg2.inner orelse return -1;
    while (i < seg1.len) : (i += 1) {
        while (j < seg2.len) : (j += 1) {
            tmp = 0;
            if (seg1_inner[i].seg_type == seg2_inner[j].seg_type) {
                continue;
            }
            if (seg1_inner[i].base_pos == 0 and seg2_inner[j].base_pos == 0) {
                continue;
            }

            if ((seg1_inner[i].base_pos >= minPos(seg2_inner[j]) and seg1_inner[i].base_pos <= maxPos(seg2_inner[j])) and
                (seg2_inner[j].base_pos >= minPos(seg1_inner[i]) and seg2_inner[j].base_pos <= maxPos(seg1_inner[i])))
            {
                k = 0;
                while (k < i) : (k += 1) {
                    tmp += math.absInt(seg1_inner[k].end - seg1_inner[k].start) catch return -1;
                }
                k = 0;
                while (k < j) : (k += 1) {
                    tmp += math.absInt(seg2_inner[k].end - seg2_inner[k].start) catch return -1;
                }
                tmp += math.absInt(seg1_inner[i].base_pos - seg2_inner[j].start) catch return -1;
                tmp += math.absInt(seg2_inner[j].base_pos - seg1_inner[i].start) catch return -1;

                answer = if (tmp <= answer) tmp else answer;
            }
        }
    }

    return answer;
}

pub fn printAnswer() !void {
    var file = try fs.cwd().openFile("./03/input.txt", .{});
    defer file.close();

    var stream = io.bufferedReader(file.reader()).reader();
    var buf = try allocator.alloc(u8, 2048);
    defer allocator.free(buf);

    var path1: Path = undefined;
    var path2: Path = undefined;
    defer path1.freePath();
    defer path2.freePath();

    if (try stream.readUntilDelimiterOrEof(buf[0..2047], '\n')) |line| {
        path1 = try parseInput(line);
    }
    if (try stream.readUntilDelimiterOrEof(buf[0..2047], '\n')) |line| {
        path2 = try parseInput(line);
    }

    var seg1 = SegmentArray.pathToSegments(&path1) orelse return error.makeSegmentFailed;
    defer seg1.freeSegArray();
    var seg2 = SegmentArray.pathToSegments(&path2) orelse return error.makeSegmentFailed;
    defer seg2.freeSegArray();

    print("Answer1: {}\n", .{solve1(&seg1, &seg2)});
    print("Answer2: {}\n", .{solve2(&seg1, &seg2)});
}
