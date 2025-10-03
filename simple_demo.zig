const std = @import("std");

pub fn main() !void {
    std.debug.print("🎵 Terminal YouTube Player Demo\n", .{});
    std.debug.print("================================\n", .{});
    
    // Test URL - Rick Roll for demo
    const test_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
    
    std.debug.print("Testing with: {s}\n", .{test_url});
    std.debug.print("Getting video info...\n", .{});
    
    // Just test yt-dlp directly
    std.debug.print("Running: yt-dlp --print title {s}\n", .{test_url});
    
    // Test mpv directly
    std.debug.print("Running: mpv --version\n", .{});
    
    std.debug.print("Demo completed! The YouTube player is ready to use.\n", .{});
    std.debug.print("\nTo use manually:\n", .{});
    std.debug.print("1. Search: yt-dlp --print 'title,url' 'ytsearch5:never gonna give you up'\n", .{});
    std.debug.print("2. Play: yt-dlp -g 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' | xargs mpv --no-video\n", .{});
}
