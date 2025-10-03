# YouTube Player - Running Instructions

## The Issue

The build is failing due to:
1. Cache directory permission issues
2. Zig API compatibility with version 0.15.1

## Solution: Run without sudo

Instead of using sudo, try these alternatives:

### Option 1: Fix cache permissions
```bash
# Create and fix the cache directory permissions
mkdir -p ~/.cache/zig
chmod -R 755 ~/.cache/zig

# Then build normally (no sudo needed)
cd /Users/yeiterilsosingkoireng/Desktop/hello-world
zig build-exe youtube.zig
```

### Option 2: Use a temporary directory
```bash
# Build in /tmp which should have proper permissions
cd /tmp
cp /Users/yeiterilsosingkoireng/Desktop/hello-world/youtube.zig .
zig build-exe youtube.zig
./youtube
```

### Option 3: Set ZIG_CACHE_DIR environment variable
```bash
# Use a custom cache directory with proper permissions
export ZIG_CACHE_DIR=/tmp/zig-cache
mkdir -p $ZIG_CACHE_DIR
cd /Users/yeiterilsosingkoireng/Desktop/hello-world
zig build-exe youtube.zig
```

### Option 4: Simple direct execution
Since you already have the simple YouTube player code, you can also run it without compiling by fixing the Zig code first. The main issue is the `std.io.getStdIn()` API has changed in Zig 0.15.1.

## Quick Test (if dependencies are installed)

If you have `yt-dlp` and `mpv` installed, you can test the core functionality directly:

```bash
# Play a video (audio only)
yt-dlp -g "https://www.youtube.com/watch?v=dQw4w9WgXcQ" | xargs mpv --no-video

# Search for videos
yt-dlp --print "title,url" "ytsearch5:never gonna give you up"
```

## Checking Dependencies

```bash
# Check if yt-dlp is installed
which yt-dlp

# Check if mpv is installed  
which mpv

# If not installed:
brew install yt-dlp mpv
```

## Why Sudo Isn't Needed (and causes problems)

- Building Zig programs doesn't require sudo
- Sudo changes the cache directory ownership to root
- This creates permission conflicts
- The YouTube player itself doesn't need elevated permissions

## Alternative: Python-based YouTube Player

If the Zig compilation continues to have issues, I can create a simple Python version that will work immediately with the same dependencies.
