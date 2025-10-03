#!/bin/bash

# Simple YouTube Audio Player using afplay (macOS built-in)
echo "🎵 Simple YouTube Audio Player"
echo "=============================="

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

# Get stream URL
echo "🎵 Getting audio stream..."
STREAM_URL=$(yt-dlp -g "$URL" --no-warnings --quiet 2>/dev/null | head -1)

if [ -z "$STREAM_URL" ]; then
    echo "❌ Could not get stream URL"
    exit 1
fi

echo "🎵 Playing audio with afplay..."
echo "Press Ctrl+C to stop"
echo ""

# Download and play with afplay (macOS built-in audio player)
yt-dlp -x --audio-format mp3 --output "/tmp/youtube_audio.%(ext)s" "$URL" --no-warnings --quiet
if [ -f "/tmp/youtube_audio.mp3" ]; then
    afplay "/tmp/youtube_audio.mp3"
    rm -f "/tmp/youtube_audio.mp3"
else
    echo "❌ Failed to download audio"
    exit 1
fi
