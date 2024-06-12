const std = @import("std");

const AllocatorPtr = *anyopaque;
const RandPtr = *anyopaque;
const GameStatePtr = *anyopaque;

var gameInit: *const fn (AllocatorPtr, RandPtr) GameStatePtr = undefined;
var gameDeinit: *const fn (GameStatePtr) void = undefined;
var gameReload: *const fn (GameStatePtr) void = undefined;
var gameShouldReload: *const fn (GameStatePtr) bool = undefined;
var gameRun: *const fn (GameStatePtr) bool = undefined;

pub fn main() !void {
    if (std.os.argv.len < 2) {
        return error.LibPathRequired;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch @panic("unable to get random");
        break :blk seed;
    });

    const lib_name = std.os.argv[1];
    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const lib_path = try std.fmt.bufPrint(&buf, "zig-out/lib/lib{s}.dylib", .{lib_name});

    try loadGameLib(lib_path);
    defer unloadGameLib(lib_path) catch |err| std.log.err("Failed to unload lib: {}", .{err});

    const state = gameInit(&allocator, &prng);
    defer gameDeinit(state);
    while (gameRun(state)) {
        if (gameShouldReload(state)) {
            try unloadGameLib(lib_path);
            try recompileGameLib(allocator, lib_path);
            try loadGameLib(lib_path);
            gameReload(state);
        }
    }
}

var game_lib: ?std.DynLib = null;

fn loadGameLib(path: []const u8) !void {
    if (game_lib != null) return error.AlreadyLoaded;
    var dl = try std.DynLib.open(path);
    game_lib = dl;
    gameInit = dl.lookup(@TypeOf(gameInit), "gameInit") orelse return error.LookupFail;
    gameDeinit = dl.lookup(@TypeOf(gameDeinit), "gameDeinit") orelse return error.LookupFail;
    gameReload = dl.lookup(@TypeOf(gameReload), "gameReload") orelse return error.LookupFail;
    gameShouldReload = dl.lookup(@TypeOf(gameShouldReload), "gameShouldReload") orelse return error.LookupFail;
    gameRun = dl.lookup(@TypeOf(gameRun), "gameRun") orelse return error.LookupFail;
    std.log.info("Loaded {s}", .{std.fs.path.basename(path)});
}

fn unloadGameLib(path: []const u8) !void {
    if (game_lib) |*dl| {
        dl.close();
        game_lib = null;
        std.log.info("Unloaded {s}", .{std.fs.path.basename(path)});
    } else {
        return error.AlreadyUnloaded;
    }
}

fn recompileGameLib(allocator: std.mem.Allocator, path: []const u8) !void {
    const process_args = [_][]const u8{
        "zig",
        "build",
        "-Dproject_only=true",
    };
    var build_process = std.process.Child.init(&process_args, allocator);
    try build_process.spawn();

    const term = try build_process.wait();
    switch (term) {
        .Exited => |exited| {
            if (exited == 0) {
                std.log.info("Recompiled {s}", .{std.fs.path.basename(path)});
                return;
            }

            if (exited == 2) return error.RecompileFail;
        },
        else => return,
    }
}
