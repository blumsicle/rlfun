const std = @import("std");
const rl = @import("raylib");

const Options = @import("options");
const Walker = @import("walker.zig");

pub const title = "Walker";
pub const screen_width = 800;
pub const screen_height = 600;

const Self = @This();

const Mode = enum(u8) {
    random,
    follow,
};

allocator: std.mem.Allocator,
options: Options,

walkers: std.ArrayList(Walker),
mode: Mode,

pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
    var self = .{
        .allocator = allocator,
        .options = options,
        .walkers = std.ArrayList(Walker).init(allocator),
        .mode = .random,
    };

    try self.walkers.append(
        Walker.new(
            rl.Vector2.init(
                @as(f32, @floatFromInt(options.screen_width)) / 2.0,
                @as(f32, @floatFromInt(options.screen_height)) / 2.0,
            ),
        ),
    );

    return self;
}

pub fn deinit(self: *Self) !void {
    self.walkers.deinit();
}

pub fn reload(self: *Self) !void {
    _ = self;
}

pub fn update(self: *Self) !void {
    if (rl.isKeyPressed(.key_space)) {
        const modes = std.enums.values(Mode);
        const mode = @intFromEnum(self.mode);
        self.mode = @enumFromInt(@mod(mode + 1, modes.len));
    }

    const prev_walker = self.walkers.getLast();
    var walker = Walker.new(prev_walker.pos);
    walker.update(self);
    try self.walkers.append(walker);
}

pub fn draw(self: *Self) !void {
    rl.clearBackground(rl.Color.ray_white);

    for (self.walkers.items) |*w| {
        w.draw();
    }

    const mode_name = std.enums.tagName(Mode, self.mode);
    if (mode_name) |n| {
        var buf: [64]u8 = undefined;
        const out = try std.fmt.bufPrintZ(&buf, "Mode: {s}", .{n});
        rl.drawText(out, 10, 10, 24, rl.Color.dark_gray);
    }
}
