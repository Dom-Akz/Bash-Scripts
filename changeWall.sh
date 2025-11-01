#!/bin/bash

SWITCH_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"
MR_WALL="$HOME/Pictures/Wallpapers/MR_WALL"
NG_WALL="$HOME/Pictures/Wallpapers/NG_WALL"
LIST_FILE="/tmp/wallpaper_list.txt"
STATE_FILE="/tmp/wallpaper_state.txt"


timeofday(){
    local h=$(date +%H)
    if [ "$h" -ge 9 ] && [ "$h" -lt 18 ];then
        echo "morning"
    else
        echo "night"
    fi
}

init_wallpaper_list() {
    find "$1" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.mp4" \) | shuf > "$LIST_FILE"
    echo "0" > "$STATE_FILE"
}

[ ! -f "$LIST_FILE" ] || [ ! -s "$LIST_FILE" ] && init_wallpaper_list "$MR_WALL"

last_run=0
WALL_DIR="$MR_WALL"
while true; do
    current_time=$(date +%s)
    if [ $((current_time - last_run)) -ge 3600 ];then
        tm_day=$(timeofday)
        last_run=$current_time
        if [ "$tm_day" = "night" ] && [ "$WALL_DIR" != "$NG_WALL" ]; then
            WALL_DIR="$NG_WALL"
            init_wallpaper_list "$WALL_DIR"
        elif [ "$tm_day" = "morning" ] && [ "$WALL_DIR" != "$MR_WALL" ]; then
            WALL_DIR="$MR_WALL"
            init_wallpaper_list "$WALL_DIR"
        fi
    fi
    current_index=$(cat "$STATE_FILE")
    total_files=$(wc -l < "$LIST_FILE")
    [ "$current_index" -ge "$total_files" ] && init_wallpaper_list "$WALL_DIR" && current_index=0
    next_line=$((current_index + 1))
    IMG=$(sed -n "${next_line}p" "$LIST_FILE")
    echo "$((current_index + 1))" > "$STATE_FILE"
    bash "$SWITCH_SCRIPT" --image "$IMG" --mode dark --type auto >/dev/null 2>&1
    sleep 400
done
