const std = @import("std");
const rl = @import("raylib");

const Options = @import("options");

pub const title = "Simple Template";
pub const screen_width = 800;
pub const screen_height = 600;

const Self = @This();

allocator: std.mem.Allocator,
options: Options,

pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
    return .{
        .allocator = allocator,
        .options = options,
    };
}

pub fn deinit(self: *Self) !void {
    _ = self;
}

pub fn reload(self: *Self) !void {
    _ = self;
}

pub fn update(self: *Self) !void {
    _ = self;
}

pub fn draw(self: *Self) !void {
    rl.clearBackground(rl.Color.ray_white);
    rl.drawCircle(@divTrunc(self.options.screen_width, 2), @divTrunc(self.options.screen_height, 2), 30.0, rl.Color.sky_blue);
}
