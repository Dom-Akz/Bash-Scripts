#!/bin/bash

# get date once
date_=$(date +%d-%m-%y)

SWITCH_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"
MR_WALL="$HOME/Pictures/Wallpapers/MR_WALL"
NG_WALL="$HOME/Pictures/Wallpapers/NG_WALL"
LIST_FILE="/tmp/wallpaper_list.txt"
STATE_FILE="/tmp/wallpaper_state.txt"
DEFAULT_IMG="$HOME/Pictures/WALL/sdpf.png"
SM_WALL="$HOME/Pictures/Wallpapers/SM"
RAIN_WALL="$HOME/Pictures/Wallpapers/RAIN"
VID_WALL="$HOME/Pictures/Wallpapers/VID_WALL/"
LOG_="$HOME/.local/bin/wall-log/chwall-$date_.log" # path to log file. every day it create new one.

# only run one time
LAT=$(curl -s https://ipinfo.io/loc | cut -d, -f1)
LONG=$(curl -s https://ipinfo.io/loc | cut -d, -f2)

timeofday() {
	local h=$(date +%H)
	if [ "$h" -gt 9 ] && [ "$h" -lt 18 ]; then
		echo "morning"
	else
		echo "night"
	fi
}

isHot() {
	local deg=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current=temperature_2m" |
		grep -o '"temperature_2m":[0-9.\-]*' |
		cut -d: -f2)
	if [ -z "$deg" ] || [ "$deg" == "null" ]; then
		return 1
	fi
	deg=$(printf "%.0f" "$deg")
	if [ $deg -gt 20 ]; then
		return 0 # hot day
	else
		return 1 # it's freezing out here
	fi
}

isRain() {
	local rain=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current=precipitation" |
		grep -o '"precipitation":[0-9.]*' | cut -d: -f2)

	if [[ -z "$rain" ]] || [[ "$rain" == "null" ]]; then
		echo "null"
	elif (($(echo "$rain > 0" | bc -l 2>/dev/null))); then
		return 0 # rain
	else
		return 1 # no rain
	fi
}

log-to-file() {
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo -e "\n[$(date)]\n WARNING: no information was given" >>$LOG_
	else
		local dir="$1"

		local curr_wall="$2" # if the default wall
		local -n arr=$3      # using the original array
		local msg="ERROR:NO MESSAGES WAS FOUND"

		if [ "${#arr[@]}" -gt 0 ]; then   # check if the array is not empty
			msg=$(printf "%s\n" "${arr[@]}") # joined the array into a string
		fi

		echo -e "[$(date)]\nWallpapers Directory:"$dir"\nCurrent Wallpaper:"$curr_wall"\n$msg
			" >>"$LOG_"
	fi
}

init_wallpaper_list() {
	find "$1" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.mp4" \) | shuf >"$LIST_FILE"
	echo "0" >"$STATE_FILE"
}

[ ! -f "$LIST_FILE" ] || [ ! -s "$LIST_FILE" ] && init_wallpaper_list "$MR_WALL"

run_time=$(ps aux | grep .local/bin/changeWall.sh | awk 'NR==1 {print $9}')
last_run=0
WALL_DIR="$MR_WALL"
while true; do

	current_time=$(date +%s)
	info=()

	if [ $((current_time - last_run)) -ge 3600 ]; then

		tm_day=$(timeofday)
		last_run=$current_time

		if isHot; then
			WALL_DIR="$SM_WALL"
			init_wallpaper_list "$WALL_DIR"
		elif isRain; then
			WALL_DIR="$RAIN_WALL"
			init_wallpaper_list "$WALL_DIR"
		elif [ "$tm_day" = "night" ] && [ "$WALL_DIR" != "$NG_WALL" ]; then
			WALL_DIR="$NG_WALL"
			init_wallpaper_list "$WALL_DIR"
		elif [ "$tm_day" = "morning" ] && [ "$WALL_DIR" != "$MR_WALL" ]; then
			WALL_DIR="$MR_WALL"
			init_wallpaper_list "$WALL_DIR"
		fi
	fi

	current_index=$(cat "$STATE_FILE")
	total_files=$(wc -l <"$LIST_FILE")
	[ "$current_index" -ge "$total_files" ] && init_wallpaper_list "$WALL_DIR" && current_index=0
	next_line=$((current_index + 1))
	IMG=$(sed -n "${next_line}p" "$LIST_FILE")
	echo "$((current_index + 1))" >"$STATE_FILE"
	wall_exists=$(find "$WALL_DIR" -wholename "$IMG" | wc -l)
	if [ "$wall_exists" -eq 0 ]; then
		IMG="$DEFAULT_IMG"
		info+=("Using default image: $DEFAULT_IMG")
	fi

	info+=("Total wallpapers: $total_files")
	if [ "$last_run" == "$current_time" ] && [ -z "$run_time" ]; then
		info+=("New wallpaper directory: "$(date +%H:%M)"")
	fi
	if [ -n "$run_time" ]; then
		info+=("Start runnig at: $run_time")
		run_time=""
	fi

	log-to-file "$WALL_DIR" "$IMG" info # this call dose not create a copy so the function use the original array
	bash $SWITCH_SCRIPT --image "$IMG" --mode dark --type auto >/dev/null 2>&1
	sleep 350

done
