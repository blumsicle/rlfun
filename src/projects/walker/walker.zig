const std = @import("std");
const rl = @import("raylib");

const State = @import("state.zig");

const Self = @This();

pos: rl.Vector2,
radius: f32,
color: rl.Color,

const Direction = enum { neg, none, pos };

pub fn new(pos: rl.Vector2) Self {
    return .{
        .pos = pos,
        .radius = 5.0,
        .color = rl.Color.dark_blue,
    };
}

pub fn update(self: *Self, state: *State) void {
    const x_dir = state.options.rand.enumValue(Direction);
    const y_dir = state.options.rand.enumValue(Direction);
    const speed = self.radius * 2.0;

    switch (x_dir) {
        .neg => self.pos.x -= speed,
        .pos => self.pos.x += speed,
        else => {},
    }

    switch (y_dir) {
        .neg => self.pos.y -= speed,
        .pos => self.pos.y += speed,
        else => {},
    }
}

pub fn draw(self: *const Self) void {
    rl.drawCircleV(self.pos, self.radius, self.color);
}
