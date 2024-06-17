const std = @import("std");
const rl = @import("raylib");

const Options = @import("options");

pub const title = "Random Distribution";
pub const screen_width = 800;
pub const screen_height = 600;

const Self = @This();

const rect_width = 20;
const num_counts = @divTrunc(screen_width, rect_width);

allocator: std.mem.Allocator,
options: Options,

counts: [num_counts]u32,
start_time: std.time.Instant,

pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
    return .{
        .allocator = allocator,
        .options = options,
        .counts = .{0} ** num_counts,
        .start_time = try std.time.Instant.now(),
    };
}

pub fn deinit(self: *Self) !void {
    _ = self;
}

pub fn reload(self: *Self) !void {
    _ = self;
}

pub fn update(self: *Self) !void {
    const current_time = try std.time.Instant.now();
    const elapsed_ns = current_time.since(self.start_time);

    if (elapsed_ns < 5 * std.time.ns_per_s) {
        for (0..50) |_| {
            const n = self.options.rand.intRangeLessThan(u32, 0, num_counts);
            self.counts[n] += 1;
        }
    }
}

pub fn draw(self: *Self) !void {
    rl.clearBackground(rl.Color.ray_white);

    const mouse_x: f32 = @floatFromInt(rl.getMouseX());
    const pos_x: i32 = @intFromFloat(num_counts * (mouse_x / screen_width));
    const pos_y: i32 = screen_height - rl.getMouseY();

    for (self.counts, 0..) |c, i| {
        const ic: i32 = @intCast(c);
        const ii: i32 = @intCast(i);
        const color = if (ii == pos_x and pos_y <= ic and pos_y >= 0) rl.Color.beige else rl.Color.light_gray;

        rl.drawRectangle(
            ii * rect_width,
            screen_height - ic,
            rect_width,
            ic,
            color,
        );

        rl.drawRectangleLines(
            ii * rect_width,
            @as(i32, screen_height) - ic,
            rect_width,
            ic,
            rl.Color.dark_gray,
        );

        var buf: [16]u8 = undefined;
        const ns = try std.fmt.bufPrintZ(&buf, "{d}", .{i});
        rl.drawText(
            ns,
            ii * rect_width + 5,
            screen_height - 20,
            10,
            rl.Color.dark_gray,
        );
    }

    if (pos_x >= 0 and pos_x < num_counts and pos_y <= self.counts[@intCast(pos_x)] and pos_y >= 0) {
        var buf: [16]u8 = undefined;
        const count = try std.fmt.bufPrintZ(&buf, "count: {d}", .{self.counts[@intCast(pos_x)]});
        rl.drawText(count, 10, 10, 24, rl.Color.dark_gray);
    }
}
