#!/bin/bash

# Simple YouTube Player - Direct approach
echo "🎵 Simple YouTube Player"
echo "========================"
echo ""

# Test if dependencies are available
if ! command -v yt-dlp &> /dev/null; then
    echo "Error: yt-dlp not found. Please install it first."
    exit 1
fi

if ! command -v mpv &> /dev/null; then
    echo "Error: mpv not found. Please install it first."
    exit 1
fi

echo "✅ Dependencies found!"
echo ""
echo "Usage examples:"
echo "  ./simple_player.sh 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'"
echo "  ./simple_player.sh 'never gonna give you up'"
echo ""

# Get the URL or search term
if [ -z "$1" ]; then
    echo "Please provide a YouTube URL or search term:"
    echo "Example: ./simple_player.sh 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'"
    exit 1
fi

INPUT="$1"

# Check if it's a URL or search term
if [[ "$INPUT" == *"youtube.com"* ]] || [[ "$INPUT" == *"youtu.be"* ]]; then
    echo "🎵 Playing: $INPUT"
    URL="$INPUT"
else
    echo "🔍 Searching for: $INPUT"
    # Get the first search result URL
    URL=$(yt-dlp --print "url" "ytsearch1:$INPUT" --no-warnings --quiet 2>/dev/null | head -1)
    if [ -z "$URL" ]; then
        echo "❌ No results found for: $INPUT"
        exit 1
    fi
    echo "📺 Found: $URL"
fi

echo "🎵 Getting stream URL..."
# Get the direct stream URL
STREAM_URL=$(yt-dlp -g "$URL" --no-warnings --quiet 2>/dev/null | head -1)

if [ -z "$STREAM_URL" ]; then
    echo "❌ Could not get stream URL"
    exit 1
fi

echo "🎵 Starting playback..."
echo "Press Ctrl+C to stop"
echo ""

# Play with mpv - force audio only
mpv --no-video --audio-only "$STREAM_URL"
