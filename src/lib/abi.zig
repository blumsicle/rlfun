const std = @import("std");
const rl = @import("raylib");

const State = @import("state");
const Options = @import("options");

export fn gameInit(allocator: *std.mem.Allocator, prng: *std.rand.Xoshiro256) *State {
    const state = allocator.create(State) catch @panic("unable to allocate state");
    state.* = State.init(allocator.*, .{
        .title = State.title,
        .screen_width = State.screen_width,
        .screen_height = State.screen_height,
        .rand = prng.random(),
    }) catch @panic("unable to init");

    rl.initWindow(State.screen_width, State.screen_height, State.title);
    rl.setTargetFPS(60);

    return state;
}

export fn gameDeinit(state: *State) void {
    var allocator = state.allocator;

    state.deinit() catch @panic("unable to deinit");
    allocator.destroy(state);

    rl.closeWindow();
}

export fn gameReload(state: *State) void {
    state.reload() catch @panic("unable to reload");
}

export fn gameShouldReload(_: *State) bool {
    if (rl.isKeyPressed(.key_f5)) return true;
    return false;
}

export fn gameRun(state: *State) bool {
    state.update() catch @panic("unable to update");

    rl.beginDrawing();
    defer rl.endDrawing();

    state.draw() catch @panic("unable to draw");

    return !rl.windowShouldClose();
}
