# Terminal YouTube Player

A terminal-based YouTube player written in Zig that allows you to search, play, and manage YouTube videos directly from your command line.

## Features

- 🎵 **Audio-only playback** - Play YouTube videos as audio streams
- 🔍 **Search functionality** - Search for YouTube videos by query
- 📋 **Playlist support** - Play entire YouTube playlists
- 🎨 **Colorful terminal UI** - Beautiful colored output with video information
- ⚡ **Fast and lightweight** - Built with Zig for performance

## Prerequisites

Before using this YouTube player, you need to install the following dependencies:

### Required Tools

1. **yt-dlp** - For extracting YouTube video information and stream URLs
   ```bash
   # macOS (using Homebrew)
   brew install yt-dlp
   
   # Or using pip
   pip install yt-dlp
   ```

2. **mpv** - For audio/video playback
   ```bash
   # macOS (using Homebrew)
   brew install mpv
   
   # Ubuntu/Debian
   sudo apt install mpv
   
   # Arch Linux
   sudo pacman -S mpv
   ```

3. **Zig** - To compile the application
   ```bash
   # Download from https://ziglang.org/download/
   # Or using package managers
   ```

## Building

```bash
# Build the YouTube player
zig build

# Or build directly
zig build-exe youtube.zig
```

## Usage

### Running the Player

```bash
# Using zig build
zig build youtube

# Or run the executable directly
./zig-out/bin/youtube_player
```

### Commands

Once the player is running, you can use these commands:

- `play <url>` - Play a specific YouTube video
- `search <query>` - Search for videos on YouTube
- `playlist <url>` - Play a YouTube playlist
- `help` - Show available commands
- `quit` - Exit the player

### Examples

```bash
# Play a specific video
play https://www.youtube.com/watch?v=dQw4w9WgXcQ

# Search for videos
search never gonna give you up

# Play a playlist
playlist https://www.youtube.com/playlist?list=PLrAXtmRdnEQy6nuLMOVnF7qpxR3gQzG0h

# After searching, play a specific result
play 1  # Plays the first search result
```

## How It Works

1. **Video Information**: Uses `yt-dlp` to extract video metadata (title, duration, etc.)
2. **Stream URL**: Gets the direct media URL for audio streaming
3. **Playback**: Uses `mpv` for high-quality audio playback
4. **Search**: Leverages `yt-dlp`'s search functionality to find videos
5. **Playlists**: Automatically plays all videos in a playlist sequentially

## Features in Detail

### Search Results
- Shows video titles and durations
- Numbered results for easy selection
- Supports playing results by number

### Playlist Support
- Lists all videos in the playlist
- Shows progress during playback
- Handles errors gracefully (skips problematic videos)

### Error Handling
- Comprehensive error messages
- Graceful fallbacks for network issues
- Memory management with proper cleanup

## Troubleshooting

### Common Issues

1. **"yt-dlp not found"**
   - Make sure yt-dlp is installed and in your PATH
   - Try running `yt-dlp --version` to verify installation

2. **"mpv not found"**
   - Install mpv using your package manager
   - Verify with `mpv --version`

3. **Network errors**
   - Check your internet connection
   - Some videos may be region-restricted
   - Try updating yt-dlp: `pip install --upgrade yt-dlp`

4. **Permission errors during build**
   - Try building in a different directory
   - Check file permissions
   - Use `sudo` if necessary (not recommended)

### Performance Tips

- The player uses audio-only mode by default for better performance
- Large playlists may take time to load
- Use Ctrl+C to stop playback at any time

## Contributing

This is a simple terminal YouTube player built as a learning project. Feel free to:

- Add new features
- Improve error handling
- Optimize performance
- Add more playback controls

## License

This project is open source and available under the MIT License.
