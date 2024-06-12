const std = @import("std");
const rl = @import("raylib");

const Options = @import("options");

pub const title = "Random Dots";
pub const screen_width = 800;
pub const screen_height = 600;

const Self = @This();

allocator: std.mem.Allocator,
options: Options,

dots: std.ArrayList(Dot),

last_created_time: f32 = 0,
time: f32 = 0,

const max_time = 0.05;

const Dot = struct {
    const min_radius = 10.0;
    const max_radius = 20.0;

    pos: rl.Vector2,
    radius: f32,
    color: rl.Color,
};

pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
    return .{
        .allocator = allocator,
        .options = options,
        .dots = std.ArrayList(Dot).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.dots.deinit();
}

pub fn reload(self: *Self) void {
    _ = self;
}

pub fn update(self: *Self) void {
    self.time += rl.getFrameTime();
    if (self.time - self.last_created_time > max_time) {
        self.last_created_time = self.time;

        const x = self.options.rand.float(f32) * @as(f32, @floatFromInt(self.options.screen_width));
        const y = self.options.rand.float(f32) * @as(f32, @floatFromInt(self.options.screen_height));

        const radius = self.options.rand.float(f32) * (Dot.max_radius - Dot.min_radius) + Dot.min_radius;

        const r = self.options.rand.intRangeAtMost(u8, 0, 255);
        const g = self.options.rand.intRangeAtMost(u8, 0, 255);
        const b = self.options.rand.intRangeAtMost(u8, 0, 255);

        self.dots.append(.{
            .pos = rl.Vector2.init(x, y),
            .radius = radius,
            .color = rl.Color.init(r, g, b, 255),
        }) catch @panic("unable to append dot");
    }
}

pub fn draw(self: *Self) void {
    rl.clearBackground(rl.Color.ray_white);

    for (self.dots.items) |dot| {
        rl.drawCircleV(dot.pos, dot.radius, dot.color);
    }
}
