#!/bin/bash

# Clean YouTube Audio Player
echo "🎵 YouTube Audio Player"
echo "======================"

# Get URL from argument
if [ -z "$1" ]; then
    echo "Usage: $0 <youtube_url_or_search_term>"
    exit 1
fi

INPUT="$1"

# Check if it's a URL or search term
if [[ "$INPUT" == *"youtube.com"* ]] || [[ "$INPUT" == *"youtu.be"* ]]; then
    URL="$INPUT"
    echo "🎵 Playing: $URL"
else
    echo "🔍 Searching for: $INPUT"
    URL=$(yt-dlp --print "url" "ytsearch1:$INPUT" --no-warnings --quiet 2>/dev/null | head -1)
    if [ -z "$URL" ]; then
        echo "❌ No results found"
        exit 1
    fi
    echo "📺 Found: $URL"
fi

# Get stream URL and play directly
echo "🎵 Getting audio stream..."
STREAM_URL=$(yt-dlp -g "$URL" --no-warnings --quiet 2>/dev/null | head -1)

if [ -z "$STREAM_URL" ]; then
    echo "❌ Could not get stream URL"
    exit 1
fi

echo "🎵 Playing audio..."
echo "Press Ctrl+C to stop"
echo ""

# Play audio with mpv - force audio only mode with proper audio output
exec mpv --no-video --audio-only --really-quiet --ao=coreaudio "$STREAM_URL"
