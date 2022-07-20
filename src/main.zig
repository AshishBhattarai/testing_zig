const std = @import("std");
const process = @import("std").process;
const File = std.fs.File;
const Parser = @import("parser.zig").Parser;

pub fn main() !void {
    // os.argv[] - POSIX only
    var args = process.args();
    _ = args.skip();
    const arg1 = args.next();
    var parser = Parser.init();

    if (arg1) |val| {
        var buffer: [10]u8 = undefined;
        const reader = try readerFromSource(val);
        while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            try parser.process(line);
        }
    }

    for (parser.instruction_table.items) |instruction| {
        std.log.info("Ins: {c}, param: {d}", .{instruction.type, instruction.argument});
    }
}

fn readerFromSource(fileName: []const u8) !File.Reader {
    const file = try std.fs.cwd().openFile(fileName, .{ .mode = File.OpenMode.read_only });
    return file.reader();
}

fn readSource(fileName: []const u8) !void {
    const file = try std.fs.cwd().openFile(fileName, .{ .mode = File.OpenMode.read_only });
    const allocator = std.heap.page_allocator;

    const fileContent = try file.readToEndAlloc(allocator, 5000);
    defer allocator.free(fileContent);

    std.log.info("Content: {s}", .{fileContent});

    defer file.close();
}
