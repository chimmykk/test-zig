#!/bin/bash

# Clean YouTube Audio Player with Audio Fix
echo "🎵 YouTube Audio Player (Fixed)"
echo "==============================="

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

# Try different audio output methods for macOS
echo "🔊 Testing audio output..."

# Method 1: Try coreaudio (macOS default)
if mpv --no-video --audio-only --really-quiet --ao=coreaudio --length=5 "$STREAM_URL" 2>/dev/null; then
    echo "✅ Audio working with coreaudio!"
    exec mpv --no-video --audio-only --really-quiet --ao=coreaudio "$STREAM_URL"
fi

# Method 2: Try pulseaudio
if mpv --no-video --audio-only --really-quiet --ao=pulse --length=5 "$STREAM_URL" 2>/dev/null; then
    echo "✅ Audio working with pulseaudio!"
    exec mpv --no-video --audio-only --really-quiet --ao=pulse "$STREAM_URL"
fi

# Method 3: Try default audio
if mpv --no-video --audio-only --really-quiet --length=5 "$STREAM_URL" 2>/dev/null; then
    echo "✅ Audio working with default output!"
    exec mpv --no-video --audio-only --really-quiet "$STREAM_URL"
fi

# Method 4: Try with volume boost
echo "🔊 Trying with volume boost..."
exec mpv --no-video --audio-only --really-quiet --ao=coreaudio --volume=100 "$STREAM_URL"
