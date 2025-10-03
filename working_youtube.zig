const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("Terminal YouTube Player\n", .{});
    std.debug.print("Commands: play <url>, search <query>, quit\n", .{});

    var input_buf: [1024]u8 = undefined;
    
    while (true) {
        std.debug.print("yt-player> ", .{});
        
        // Use the correct stdin API for Zig 0.15.1
        const stdin = std.io.getStdIn();
        const reader = stdin.reader();
        if (try reader.readUntilDelimiterOrEof(input_buf[0..], '\n')) |input| {
            var args = std.mem.split(u8, input, " ");
            const command = args.next() orelse continue;
            
            if (std.mem.eql(u8, command, "quit") or std.mem.eql(u8, command, "exit")) {
                std.debug.print("Goodbye!\n", .{});
                break;
            } else if (std.mem.eql(u8, command, "play")) {
                const url = args.rest();
                if (url.len == 0) {
                    std.debug.print("Error: Please provide a YouTube URL\n", .{});
                    continue;
                }
                
                try playVideo(url, allocator);
            } else if (std.mem.eql(u8, command, "search")) {
                const query = args.rest();
                if (query.len == 0) {
                    std.debug.print("Error: Please provide a search query\n", .{});
                    continue;
                }
                
                try searchVideos(query, allocator);
            } else {
                std.debug.print("Unknown command: {s}\n", .{command});
                std.debug.print("Type 'help' for available commands\n", .{});
            }
        }
    }
}

fn playVideo(url: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("Getting video info...\n", .{});
    
    // Get video title using yt-dlp
    var yt_cmd = std.process.Child.init(&[_][]const u8{
        "yt-dlp", "--print", "title", url,
    }, allocator);
    
    yt_cmd.stdout_behavior = .Pipe;
    try yt_cmd.spawn();
    
    var stdout_stream = yt_cmd.stdout.?.reader();
    var buf: [4096]u8 = undefined;
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
    
    var stream_stdout = stream_cmd.stdout.?.reader();
    var stream_buf: [4096]u8 = undefined;
    const stream_n = try stream_stdout.readAll(&stream_buf);
    const stream_url = stream_buf[0..stream_n];
    
    _ = try stream_cmd.wait();
    
    // Clean URL
    const clean_url = std.mem.trim(u8, stream_url, "\n\r");
    
    // Play with mpv
    std.debug.print("Starting playback...\n", .{});
    var mpv_cmd = std.process.Child.init(&[_][]const u8{
        "mpv", "--no-video", clean_url,
    }, allocator);
    
    try mpv_cmd.spawn();
    _ = try mpv_cmd.wait();
}

fn searchVideos(query: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("Searching for: {s}\n", .{query});
    
    var search_cmd = std.process.Child.init(&[_][]const u8{
        "yt-dlp", "--print", "title,url", "ytsearch5:{s}",
    }, allocator);
    
    search_cmd.stdout_behavior = .Pipe;
    try search_cmd.spawn();
    
    var stdout_stream = search_cmd.stdout.?.reader();
    var buf: [4096]u8 = undefined;
    const n = try stdout_stream.readAll(&buf);
    const output = buf[0..n];
    
    _ = try search_cmd.wait();
    
    std.debug.print("Search Results:\n", .{});
    var lines = std.mem.split(u8, output, "\n");
    var count: u32 = 0;
    
    while (lines.next()) |line| {
        if (line.len > 0) {
            count += 1;
            std.debug.print("  {}. {s}\n", .{ count, line });
        }
    }
}
