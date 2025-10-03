const std = @import("std");

const YouTubePlayer = struct {
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) YouTubePlayer {
        return YouTubePlayer{
            .allocator = allocator,
        };
    }
    
    pub fn getVideoInfo(self: YouTubePlayer, url: []const u8) !VideoInfo {
        // Get video title and duration using yt-dlp
        var yt_cmd = std.process.Child.init(&[_][]const u8{
            "yt-dlp", "--print", "title,duration", url,
        }, self.allocator);
        
        yt_cmd.stdout_behavior = .Pipe;
        try yt_cmd.spawn();
        
        var stdout_stream = yt_cmd.stdout.?.reader();
        var buf: [4096]u8 = undefined;
        const n = try stdout_stream.readAll(&buf);
        const output = buf[0..n];
        
        _ = try yt_cmd.wait();
        
        // Parse title and duration
        var lines = std.mem.split(u8, output, "\n");
        const title = lines.next() orelse "Unknown Title";
        const duration_str = lines.next() orelse "0";
        const duration = std.fmt.parseInt(u32, duration_str, 10) catch 0;
        
        return VideoInfo{
            .title = title,
            .duration = duration,
        };
    }
    
    pub fn getStreamUrl(self: YouTubePlayer, url: []const u8) ![]u8 {
        var yt_cmd = std.process.Child.init(&[_][]const u8{
            "yt-dlp", "-g", url,
        }, self.allocator);
        
        yt_cmd.stdout_behavior = .Pipe;
        try yt_cmd.spawn();
        
        var stdout_stream = yt_cmd.stdout.?.reader();
        var buf: [4096]u8 = undefined;
        const n = try stdout_stream.readAll(&buf);
        const stream_url = buf[0..n];
        
        _ = try yt_cmd.wait();
        
        // trim newline and return owned string
        const clean_url = std.mem.trim(u8, stream_url, "\n\r");
        return self.allocator.dupe(u8, clean_url);
    }
    
    pub fn play(self: YouTubePlayer, stream_url: []const u8, audio_only: bool) !void {
        var args = std.ArrayList([]const u8).init(self.allocator);
        defer args.deinit();
        
        try args.append("mpv");
        if (audio_only) {
            try args.append("--no-video");
        }
        try args.append("--no-terminal");
        try args.append(stream_url);
        
        var mpv_cmd = std.process.Child.init(args.items, self.allocator);
        try mpv_cmd.spawn();
        _ = try mpv_cmd.wait();
    }
    
    pub fn getPlaylistVideos(self: YouTubePlayer, playlist_url: []const u8) ![]PlaylistVideo {
        var yt_cmd = std.process.Child.init(&[_][]const u8{
            "yt-dlp", "--print", "title,url,duration", playlist_url,
        }, self.allocator);
        
        yt_cmd.stdout_behavior = .Pipe;
        try yt_cmd.spawn();
        
        var stdout_stream = yt_cmd.stdout.?.reader();
        var buf: [8192]u8 = undefined;
        const n = try stdout_stream.readAll(&buf);
        const output = buf[0..n];
        
        _ = try yt_cmd.wait();
        
        // Parse playlist videos
        var videos = std.ArrayList(PlaylistVideo).init(self.allocator);
        var lines = std.mem.split(u8, output, "\n");
        
        while (lines.next()) |line| {
            if (line.len > 0) {
                var parts = std.mem.split(u8, line, "\t");
                const title = parts.next() orelse "Unknown";
                const url = parts.next() orelse "";
                const duration_str = parts.next() orelse "0";
                const duration = std.fmt.parseInt(u32, duration_str, 10) catch 0;
                
                try videos.append(PlaylistVideo{
                    .title = title,
                    .url = url,
                    .duration = duration,
                });
            }
        }
        
        return videos.toOwnedSlice();
    }
};

const VideoInfo = struct {
    title: []const u8,
    duration: u32,
};

fn printBanner() void {
    std.debug.print("\x1b[1;34m", .{});
    std.debug.print("╔══════════════════════════════════════╗\n", .{});
    std.debug.print("║        Terminal YouTube Player       ║\n", .{});
    std.debug.print("╚══════════════════════════════════════╝\n", .{});
    std.debug.print("\x1b[0m", .{});
}

fn printHelp() void {
    std.debug.print("\n\x1b[1;33mCommands:\x1b[0m\n", .{});
    std.debug.print("  \x1b[32mplay <url>\x1b[0m     - Play a YouTube video\n", .{});
    std.debug.print("  \x1b[32msearch <query>\x1b[0m - Search for videos\n", .{});
    std.debug.print("  \x1b[32mplaylist <url>\x1b[0m - Play a YouTube playlist\n", .{});
    std.debug.print("  \x1b[32mhelp\x1b[0m          - Show this help\n", .{});
    std.debug.print("  \x1b[32mquit\x1b[0m          - Exit the player\n\n", .{});
}

fn searchYouTube(allocator: std.mem.Allocator, query: []const u8) ![]SearchResult {
    std.debug.print("\x1b[1;33mSearching for: \x1b[0m{s}\n", .{query});
    
    // Use yt-dlp to search
    var search_cmd = std.process.Child.init(&[_][]const u8{
        "yt-dlp", "--print", "title,url,duration", "ytsearch5:{s}",
    }, allocator);
    
    search_cmd.stdout_behavior = .Pipe;
    try search_cmd.spawn();
    
    var stdout_stream = search_cmd.stdout.?.reader();
    var buf: [4096]u8 = undefined;
    const n = try stdout_stream.readAll(&buf);
    const output = buf[0..n];
    
    _ = try search_cmd.wait();
    
    // Parse results
    var results = std.ArrayList(SearchResult).init(allocator);
    var lines = std.mem.split(u8, output, "\n");
    var count: u32 = 0;
    
    while (lines.next()) |line| {
        if (line.len > 0) {
            var parts = std.mem.split(u8, line, "\t");
            const title = parts.next() orelse "Unknown";
            const url = parts.next() orelse "";
            const duration_str = parts.next() orelse "0";
            const duration = std.fmt.parseInt(u32, duration_str, 10) catch 0;
            
            try results.append(SearchResult{
                .title = title,
                .url = url,
                .duration = duration,
            });
            count += 1;
        }
    }
    
    std.debug.print("\n\x1b[1;36mSearch Results:\x1b[0m\n");
    for (results.items, 0..) |result, i| {
        const minutes = result.duration / 60;
        const seconds = result.duration % 60;
        std.debug.print("  \x1b[32m{}\x1b[0m. {s} \x1b[90m({}:{:0>2})\x1b[0m\n", .{ i + 1, result.title, minutes, seconds });
    }
    
    return results.toOwnedSlice();
}

const SearchResult = struct {
    title: []const u8,
    url: []const u8,
    duration: u32,
};

const PlaylistVideo = struct {
    title: []const u8,
    url: []const u8,
    duration: u32,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    printBanner();
    printHelp();
    
    var player = YouTubePlayer.init(allocator);
    var input_buf: [1024]u8 = undefined;
    var search_results: ?[]SearchResult = null;
    
    while (true) {
        std.debug.print("\x1b[1;32myt-player>\x1b[0m ", .{});
        
        if (try std.io.getStdIn().readUntilDelimiterOrEof(input_buf[0..], '\n')) |input| {
            var args = std.mem.split(u8, input, " ");
            const command = args.next() orelse continue;
            
            if (std.mem.eql(u8, command, "quit") or std.mem.eql(u8, command, "exit")) {
                std.debug.print("\x1b[1;33mGoodbye!\x1b[0m\n");
                break;
            } else if (std.mem.eql(u8, command, "help")) {
                printHelp();
            } else if (std.mem.eql(u8, command, "play")) {
                const url = args.rest();
                if (url.len == 0) {
                    std.debug.print("\x1b[1;31mError: Please provide a YouTube URL\x1b[0m\n");
                    continue;
                }
                
                try playVideo(&player, url, allocator);
            } else if (std.mem.eql(u8, command, "search")) {
                const query = args.rest();
                if (query.len == 0) {
                    std.debug.print("\x1b[1;31mError: Please provide a search query\x1b[0m\n");
                    continue;
                }
                
                // Free previous search results
                if (search_results) |results| {
                    allocator.free(results);
                }
                
                search_results = searchYouTube(allocator, query) catch |err| {
                    std.debug.print("\x1b[1;31mError searching: {}\x1b[0m\n", .{err});
                    continue;
                };
                
                std.debug.print("\n\x1b[1;33mType 'play <number>' to play a video from search results\x1b[0m\n");
            } else if (std.mem.eql(u8, command, "playlist")) {
                const url = args.rest();
                if (url.len == 0) {
                    std.debug.print("\x1b[1;31mError: Please provide a YouTube playlist URL\x1b[0m\n");
                    continue;
                }
                
                try playPlaylist(&player, url, allocator);
            } else if (std.mem.eql(u8, command, "play") and search_results != null) {
                // Handle playing from search results
                const num_str = args.next() orelse {
                    std.debug.print("\x1b[1;31mError: Please provide a number to play from search results\x1b[0m\n");
                    continue;
                };
                
                const num = std.fmt.parseInt(usize, num_str, 10) catch {
                    std.debug.print("\x1b[1;31mError: Invalid number\x1b[0m\n");
                    continue;
                };
                
                if (num < 1 or num > search_results.?.len) {
                    std.debug.print("\x1b[1;31mError: Number out of range\x1b[0m\n");
                    continue;
                }
                
                const selected = search_results.?[num - 1];
                try playVideo(&player, selected.url, allocator);
            } else {
                std.debug.print("\x1b[1;31mUnknown command: {s}\x1b[0m\n", .{command});
                std.debug.print("Type 'help' for available commands\n");
            }
        }
    }
    
    // Clean up search results
    if (search_results) |results| {
        allocator.free(results);
    }
}

fn playVideo(player: *YouTubePlayer, url: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("\x1b[1;33mGetting video info...\x1b[0m\n");
    const video_info = player.getVideoInfo(url) catch |err| {
        std.debug.print("\x1b[1;31mError getting video info: {}\x1b[0m\n", .{err});
        return;
    };
    
    std.debug.print("\x1b[1;36mTitle: \x1b[0m{s}\n", .{video_info.title});
    const minutes = video_info.duration / 60;
    const seconds = video_info.duration % 60;
    std.debug.print("\x1b[1;36mDuration: \x1b[0m{}:{:0>2}\n", .{ minutes, seconds });
    
    std.debug.print("\x1b[1;33mGetting stream URL...\x1b[0m\n");
    const stream_url = player.getStreamUrl(url) catch |err| {
        std.debug.print("\x1b[1;31mError getting stream URL: {}\x1b[0m\n", .{err});
        return;
    };
    defer allocator.free(stream_url);
    
    std.debug.print("\x1b[1;33mStarting playback...\x1b[0m\n");
    std.debug.print("\x1b[1;32mPress Ctrl+C to stop\x1b[0m\n");
    
    player.play(stream_url, true) catch |err| {
        std.debug.print("\x1b[1;31mError during playback: {}\x1b[0m\n", .{err});
    };
}

fn playPlaylist(player: *YouTubePlayer, playlist_url: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("\x1b[1;33mGetting playlist info...\x1b[0m\n");
    const videos = player.getPlaylistVideos(playlist_url) catch |err| {
        std.debug.print("\x1b[1;31mError getting playlist: {}\x1b[0m\n", .{err});
        return;
    };
    defer allocator.free(videos);
    
    std.debug.print("\n\x1b[1;36mPlaylist ({d} videos):\x1b[0m\n", .{videos.len});
    for (videos, 0..) |video, i| {
        const minutes = video.duration / 60;
        const seconds = video.duration % 60;
        std.debug.print("  \x1b[32m{}\x1b[0m. {s} \x1b[90m({}:{:0>2})\x1b[0m\n", .{ i + 1, video.title, minutes, seconds });
    }
    
    std.debug.print("\n\x1b[1;33mStarting playlist playback...\x1b[0m\n");
    std.debug.print("\x1b[1;32mPress Ctrl+C to stop\x1b[0m\n");
    
    for (videos, 0..) |video, i| {
        std.debug.print("\n\x1b[1;36mPlaying {}/{}: {s}\x1b[0m\n", .{ i + 1, videos.len, video.title });
        
        const stream_url = player.getStreamUrl(video.url) catch |err| {
            std.debug.print("\x1b[1;31mError getting stream URL for video {}: {}\x1b[0m\n", .{ i + 1, err });
            continue;
        };
        defer allocator.free(stream_url);
        
        player.play(stream_url, true) catch |err| {
            std.debug.print("\x1b[1;31mError playing video {}: {}\x1b[0m\n", .{ i + 1, err });
        };
    }
}

