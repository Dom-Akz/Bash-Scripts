#!/bin/bash

# Path to the existing Illogical Impulse wallpaper switcher
SWITCH_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"

# Optional: set wallpaper directory (update this path if you keep them elsewhere)
WALL_DIR="$HOME/Pictures/Wallpapers"

while true; do
    # Pick a random image from your wallpaper directory
    IMG=$(find "$WALL_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.mp4" \) | shuf -n 1)
    
    # Change wallpaper using Illogical Impulse’s own script
    bash "$SWITCH_SCRIPT" --image "$IMG" --mode dark --type auto
    
    # Wait 5 minutes before next change
    sleep 300
done

