const std = @import("std");

pub fn main() !void {
    var buf: [100]u8 = undefined;
    const stdin = std.io.getStdIn();
    const reader = stdin.reader();
    if (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.debug.print("Got: {s}\n", .{line});
    }
}
