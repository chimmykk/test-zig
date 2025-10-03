#!/bin/bash

echo "🔊 Testing audio system..."

# Test 1: Check if afplay works with a simple test
echo "Testing afplay..."
if command -v afplay &> /dev/null; then
    echo "✅ afplay is available"
    # Try to play a system sound
    afplay /System/Library/Sounds/Ping.aiff &
    sleep 2
    pkill afplay
    echo "✅ afplay test completed"
else
    echo "❌ afplay not found"
fi

# Test 2: Check yt-dlp
echo "Testing yt-dlp..."
if command -v yt-dlp &> /dev/null; then
    echo "✅ yt-dlp is available"
    echo "Testing download..."
    yt-dlp --print "title" "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --no-warnings --quiet
    if [ $? -eq 0 ]; then
        echo "✅ yt-dlp can access YouTube"
    else
        echo "❌ yt-dlp cannot access YouTube"
    fi
else
    echo "❌ yt-dlp not found"
fi

# Test 3: Try direct download and play
echo "Testing direct download and play..."
yt-dlp -x --audio-format mp3 --output "/tmp/test_audio.%(ext)s" "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --no-warnings --quiet --max-downloads 1
if [ -f "/tmp/test_audio.mp3" ]; then
    echo "✅ Download successful"
    echo "Playing with afplay..."
    afplay "/tmp/test_audio.mp3" &
    sleep 5
    pkill afplay
    rm -f "/tmp/test_audio.mp3"
    echo "✅ Playback test completed"
else
    echo "❌ Download failed"
fi
