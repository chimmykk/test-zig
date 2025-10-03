const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("🎵 Terminal YouTube Player Demo\n", .{});
    std.debug.print("================================\n", .{});
    
    // Test URL - Rick Roll for demo
    const test_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
    
    std.debug.print("Testing with: {s}\n", .{test_url});
    std.debug.print("Getting video info...\n", .{});
    
    try playVideo(test_url, allocator);
}

fn playVideo(url: []const u8, allocator: std.mem.Allocator) !void {
    // Get video title using yt-dlp
    var yt_cmd = std.process.Child.init(&[_][]const u8{
        "yt-dlp", "--print", "title", url,
    }, allocator);
    
    yt_cmd.stdout_behavior = .Pipe;
    try yt_cmd.spawn();
    
    var buf: [4096]u8 = undefined;
    var stdout_stream = yt_cmd.stdout.?.reader(&buf);
    const n = try stdout_stream.readAll(&buf);
    const title = buf[0..n];
    
    _ = try yt_cmd.wait();
    
    std.debug.print("Title: {s}\n", .{title});
    
    // Get stream URL
    std.debug.print("Getting stream URL...\n", .{});
    var stream_cmd = std.process.Child.init(&[_][]const u8{
        "yt-dlp", "-g", url,
    }, allocator);
    
    stream_cmd.stdout_behavior = .Pipe;
    try stream_cmd.spawn();
    
    var stream_buf: [4096]u8 = undefined;
    var stream_stdout = stream_cmd.stdout.?.reader(&stream_buf);
    const stream_n = try stream_stdout.readAll(&stream_buf);
    const stream_url = stream_buf[0..stream_n];
    
    _ = try stream_cmd.wait();
    
    // Clean URL
    const clean_url = std.mem.trim(u8, stream_url, "\n\r");
    
    std.debug.print("Stream URL: {s}\n", .{clean_url});
    
    // Play with mpv
    std.debug.print("Starting playback with mpv...\n", .{});
    std.debug.print("(This will play audio for a few seconds then exit)\n", .{});
    
    var mpv_cmd = std.process.Child.init(&[_][]const u8{
        "mpv", "--no-video", "--length=10", clean_url,
    }, allocator);
    
    try mpv_cmd.spawn();
    _ = try mpv_cmd.wait();
    
    std.debug.print("Demo completed!\n", .{});
}
