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
LOG_="/tmp/chwall-$date_.log" # path to log file. every day it create new one.

# only run one time
LAT=$(curl -s https://ipinfo.io/loc | cut -d, -f1)
LONG=$(curl -s https://ipinfo.io/loc | cut -d, -f2)

timeofday() {
	local h=$(date +%H)
	if [ "$h" -ge 9 ] && [ "$h" -lt 18 ]; then
		echo "morning"
	else
		echo "night"
	fi
}

isHot() {
	local deg=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current=temperature_2m" |
		grep -o '"temperature_2m":[0-9.\-]*' |
		cut -d: -f2)
	deg=$(printf "%.0f" "$deg")
	if [ "$deg" -gt 20 ]; then
		echo "sahd" # hot day
	else
		echo "lkaz" # it's freezing out here
	fi
}

isRain() {
	local rain=$(curl -s -f "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current=precipitation" |
		grep -o '"precipitation":[0-9.]*' | cut -d: -f2)

	if [[ -z "$rain" ]] || [[ "$rain" == "null" ]]; then
		echo "null"
	elif (($(echo "$rain > 0" | bc -l 2>/dev/null))); then
		echo "rain"
	else
		echo "no rain"
	fi
}

log-to-file() {
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo -e "\n[$(date)]\n WARNING: no information was given" >>"$LOG_"
	else
		local dir="$1"
		local curr_wall="$2"
		local msg="SCRIPTS RUNNING WITH NO ERROR OR WARNING"
		[ ! -z "$3" ] && msg="$3"

		echo -e "\n[$(date)]\nWallpapers Directory:"$dir"
			\nCurrent Wallpaper:"$curr_wall"
			\nINFO:"$msg"
			" >>"$LOG_"
	fi
}

init_wallpaper_list() {
	find "$1" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.mp4" \) | shuf >"$LIST_FILE"
	echo "0" >"$STATE_FILE"
}

[ ! -f "$LIST_FILE" ] || [ ! -s "$LIST_FILE" ] && init_wallpaper_list "$MR_WALL"

last_run=0
WALL_DIR="$MR_WALL"
while true; do

	current_time=$(date +%s)

	if [ $((current_time - last_run)) -ge 3600 ]; then

		tm_day=$(timeofday)
		whet=$(isHot)
		rain=$(isRain)
		last_run=$current_time

		if [ "$whet" == "shad" ]; then
			WALL_DIR="$SM_WALL"
			init_wallpaper_list "$WALL_DIR"
		elif [ "$rain" = "rain" ]; then
			WALL_DIR=$RAIN_WALL
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
	isExist=$(find "$WALL_DIR" -wholename "$IMG" | wc -l)
	if [ "$isExist" -eq 0 ]; then
		IMG="$DEFAULT_IMG"
	fi
	log-to-file "$WALL_DIR" "$IMG"
	bash "$SWITCH_SCRIPT" --image "$IMG" --mode dark --type auto >/dev/null 2>&1
	sleep 350
done
