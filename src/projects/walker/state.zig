const std = @import("std");
const rl = @import("raylib");

const Options = @import("options");
const Walker = @import("walker.zig");

pub const title = "Walker";
pub const screen_width = 800;
pub const screen_height = 600;

const Self = @This();

allocator: std.mem.Allocator,
options: Options,

walkers: std.ArrayList(Walker),

pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
    var self = .{
        .allocator = allocator,
        .options = options,
        .walkers = std.ArrayList(Walker).init(allocator),
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

pub fn deinit(self: *Self) void {
    self.walkers.deinit();
}

pub fn reload(self: *Self) void {
    _ = self;
}

pub fn update(self: *Self) void {
    const prev_walker = self.walkers.getLast();
    var walker = Walker.new(prev_walker.pos);
    walker.update(self);
    self.walkers.append(walker) catch @panic("unable to add walker");
}

pub fn draw(self: *Self) void {
    rl.clearBackground(rl.Color.ray_white);
    for (self.walkers.items) |*w| {
        w.draw();
    }
}
