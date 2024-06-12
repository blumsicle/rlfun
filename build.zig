const std = @import("std");

pub fn build(b: *std.Build) !void {
    const project_only = b.option(bool, "project_only", "only build the project shared library") orelse false;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
        .shared = true,
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const options = b.addModule("options", .{
        .root_source_file = b.path("src/lib/options.zig"),
        .target = target,
        .optimize = optimize,
    });

    const artifacts = [_]*std.Build.Step.Compile{raylib_artifact};
    const imports = [_]std.Build.Module.Import{
        .{ .name = "raylib", .module = raylib },
        .{ .name = "options", .module = options },
    };

    var lib_names = std.ArrayList([]const u8).init(b.allocator);
    defer lib_names.deinit();

    const pd = try std.fs.cwd().openDir("src/projects", .{ .iterate = true });
    var pd_iterator = pd.iterate();
    while (try pd_iterator.next()) |entry| {
        if (entry.kind == .directory) {
            try lib_names.append(entry.name);
        }
    }

    for (lib_names.items) |ln| {
        const lib = b.addSharedLibrary(.{
            .name = ln,
            .root_source_file = b.path("src/lib/abi.zig"),
            .target = target,
            .optimize = optimize,
            .version = .{ .major = 1, .minor = 0, .patch = 0 },
        });

        for (artifacts) |a| {
            lib.linkLibrary(a);
        }

        for (imports) |i| {
            lib.root_module.addImport(i.name, i.module);
        }

        var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const path = try std.fmt.bufPrint(&buf, "src/projects/{s}/state.zig", .{ln});
        const state = b.addModule("state", .{
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
            .imports = &imports,
        });

        lib.root_module.addImport("state", state);

        b.installArtifact(lib);
    }

    if (!project_only) {
        const exe = b.addExecutable(.{
            .name = "rlfun",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}
