const std = @import("std");
const rl = @import("raylib");

const State = @import("state.zig");

const Self = @This();

pos: rl.Vector2,
size: rl.Vector2,
color: rl.Color,

const Direction = enum { neg, none, pos };

pub fn new(pos: rl.Vector2) Self {
    return .{
        .pos = pos,
        .size = rl.Vector2.init(3.0, 3.0),
        .color = rl.Color.dark_blue,
    };
}

pub fn update(self: *Self, state: *State) void {
    const speed = self.size;
    var x_dir = state.options.rand.enumValue(Direction);
    var y_dir = state.options.rand.enumValue(Direction);

    if (state.mode == .follow) {
        var follows: [3]bool = undefined;
        for (&follows) |*f| {
            f.* = state.options.rand.boolean();
        }

        const follow = blk: {
            for (&follows) |f|
                if (!f) break :blk false;

            break :blk true;
        };

        if (follow) {
            const mouse_pos = rl.Vector2.init(
                @as(f32, @floatFromInt(rl.getMouseX())),
                @as(f32, @floatFromInt(rl.getMouseY())),
            );

            const dir = mouse_pos.subtract(self.pos);
            if (dir.x < 0) x_dir = .neg else if (dir.x > 0) x_dir = .pos else x_dir = .none;
            if (dir.y < 0) y_dir = .neg else if (dir.y > 0) y_dir = .pos else y_dir = .none;
        }
    }

    switch (x_dir) {
        .neg => self.pos.x -= speed.x,
        .pos => self.pos.x += speed.x,
        else => {},
    }

    switch (y_dir) {
        .neg => self.pos.y -= speed.y,
        .pos => self.pos.y += speed.y,
        else => {},
    }
}

pub fn draw(self: *const Self) void {
    rl.drawRectangleV(self.pos, self.size, self.color);
}
