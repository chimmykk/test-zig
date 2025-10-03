const std = @import("std");

pub fn main() !void {
    // Try different possible APIs
    std.debug.print("Testing stdin API...\n", .{});
    
    // Method 1: Direct access
    const stdin = std.io.getStdIn();
    std.debug.print("Method 1 works!\n", .{});
}
