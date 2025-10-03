#!/bin/bash

# Terminal YouTube Player
# A simple bash-based YouTube player using yt-dlp and mpv

echo "🎵 Terminal YouTube Player"
echo "=========================="
echo "Commands:"
echo "  play <url>     - Play a YouTube video"
echo "  search <query> - Search for videos"
echo "  quit          - Exit"
echo ""

while true; do
    read -p "yt-player> " command args
    
    case $command in
        "play")
            if [ -z "$args" ]; then
                echo "Error: Please provide a YouTube URL"
                continue
            fi
            
            echo "Getting video info..."
            title=$(yt-dlp --print "title" "$args" --no-warnings --quiet 2>/dev/null)
            echo "Title: $title"
            
            echo "Getting stream URL..."
            stream_url=$(yt-dlp -g "$args" --no-warnings --quiet 2>/dev/null | head -1)
            
            if [ -z "$stream_url" ]; then
                echo "Error: Could not get stream URL"
                continue
            fi
            
            echo "Starting playback..."
            echo "Press Ctrl+C to stop"
            mpv --no-video "$stream_url"
            ;;
            
        "search")
            if [ -z "$args" ]; then
                echo "Error: Please provide a search query"
                continue
            fi
            
            echo "Searching for: $args"
            echo "Results:"
            yt-dlp --print "title,url" "ytsearch5:$args" --no-warnings --quiet 2>/dev/null | nl
            ;;
            
        "quit"|"exit")
            echo "Goodbye!"
            break
            ;;
            
        *)
            echo "Unknown command: $command"
            echo "Type 'help' for available commands"
            ;;
    esac
done
