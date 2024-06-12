const std = @import("std");
const rl = @import("raylib");

const State = @import("state");
const Options = @import("options");

export fn gameInit(allocator_ptr: *anyopaque, rand_ptr: *anyopaque) *anyopaque {
    var allocator: *std.mem.Allocator = @ptrCast(@alignCast(allocator_ptr));
    var prng: *std.rand.Xoshiro256 = @ptrCast(@alignCast(rand_ptr));

    const state = allocator.create(State) catch @panic("unable to allocate state");
    state.* = State.init(allocator.*, .{
        .title = State.title,
        .screen_width = State.screen_width,
        .screen_height = State.screen_height,
        .rand = prng.random(),
    }) catch @panic("unable to create state");

    rl.initWindow(State.screen_width, State.screen_height, State.title);
    rl.setTargetFPS(60);

    return state;
}

export fn gameDeinit(state_ptr: *anyopaque) void {
    var state: *State = @ptrCast(@alignCast(state_ptr));
    var allocator = state.allocator;

    state.deinit();
    allocator.destroy(state);

    rl.closeWindow();
}

export fn gameReload(state_ptr: *anyopaque) void {
    var state: *State = @ptrCast(@alignCast(state_ptr));
    state.reload();
}

export fn gameShouldReload(_: *anyopaque) bool {
    if (rl.isKeyPressed(.key_f5)) return true;
    return false;
}

export fn gameRun(state_ptr: *anyopaque) bool {
    var state: *State = @ptrCast(@alignCast(state_ptr));

    state.update();

    rl.beginDrawing();
    defer rl.endDrawing();

    state.draw();

    return !rl.windowShouldClose();
}
