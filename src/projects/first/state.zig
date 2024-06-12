const std = @import("std");
const rl = @import("raylib");

const Options = @import("options");

pub const title = "First try";
pub const screen_width = 800;
pub const screen_height = 600;

const Self = @This();

allocator: std.mem.Allocator,
options: Options,

time: f32 = 0,
radius: f32 = 0,

config_path: []const u8 = "config/radius.txt",

pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
    var state: Self = .{
        .allocator = allocator,
        .options = options,
    };

    state.radius = readRadiusConfig(allocator, state.config_path);

    return state;
}

pub fn deinit(self: *Self) void {
    _ = self;
}

pub fn reload(self: *Self) void {
    self.radius = readRadiusConfig(self.allocator, self.config_path);
}

pub fn readRadiusConfig(allocator: std.mem.Allocator, configPath: []const u8) f32 {
    const default_value: f32 = 10.0;
    const config_data = std.fs.cwd().readFileAlloc(allocator, configPath, 1024 * 1024) catch |err| {
        std.log.err("Failed to read {s}: {}", .{ configPath, err });
        return default_value;
    };
    defer allocator.free(config_data);

    const trimmed = std.mem.trim(u8, config_data, &std.ascii.whitespace);
    return std.fmt.parseFloat(f32, trimmed) catch |err| {
        std.log.err("Failed to parse {s}: {}", .{ trimmed, err });
        return default_value;
    };
}

pub fn update(self: *Self) void {
    self.time += rl.getFrameTime();
}

pub fn draw(self: *Self) void {
    rl.clearBackground(rl.Color.ray_white);

    var buf: [256]u8 = undefined;
    const slice = std.fmt.bufPrintZ(
        &buf,
        "radius: {d:.02}, time: {d:.02}",
        .{ self.radius, self.time },
    ) catch unreachable;

    rl.drawText(slice, 10, 10, 20, rl.Color.black);

    const circle_x: f32 = @mod(self.time * 100.0, @as(f32, @floatFromInt(self.options.screen_width)));
    rl.drawCircleV(
        rl.Vector2.init(circle_x, @as(f32, @floatFromInt(self.options.screen_height)) / 2.0),
        self.radius,
        rl.Color.green,
    );
}
