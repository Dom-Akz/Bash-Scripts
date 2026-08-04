#!/usr/bin/env bash

# get date once
declare date_=$(date +%d-%m-%y)

# wallpapers
MR_WALL="$HOME/Pictures/Wallpapers/MR_WALL"
NG_WALL="$HOME/Pictures/Wallpapers/NG_WALL"
SM_WALL="$HOME/Pictures/Wallpapers/SM"
RAIN_WALL="$HOME/Pictures/Wallpapers/RAIN"
VID_WALL="$HOME/Pictures/Wallpapers/VID_WALL/"
FEM_WALL="$HOME/Pictures/Wallpapers/FEM-WALL/"
AVG_WALL="$HOME/Pictures/WALL/walls/"

LIST_FILE="/tmp/wallpaper_list.txt"
STATE_FILE="/tmp/wallpaper_state.txt"

DEFAULT_IMG="$HOME/Pictures/WALL/anime_skull.png"      # add check if the img exist or not
LOG_="$HOME/.local/share/chwall/Wallpapers-$date_.log" # path to log file. every day it create new one.

declare -r LAT=$(curl -s https://ipinfo.io/loc | cut -d, -f1)
declare -r LONG=$(curl -s https://ipinfo.io/loc | cut -d, -f2)

timeofday() {
	local h=$(date +%H)
	if [ "$h" -gt 7 ] && [ "$h" -lt 20 ]; then
		echo "morning"
	else
		echo "night"
	fi
}

isHot() {
	local deg=$(curl -s --connect-timeout 10 --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current=temperature_2m" |
		grep -o '"temperature_2m":[0-9.\-]*' |
		cut -d: -f2)
	if [ -z "$deg" ] || [ "$deg" == "null" ]; then
		return 1
	fi
	deg=$(printf "%.0f" "$deg")
	if [ $deg -gt 27 ]; then
		return 0 # hot day
	else
		return 1 # it's freezing out here
	fi
}

isRain() {
	local rain=$(curl -s --connect-timeout 10 --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current=precipitation" |
		grep -o '"precipitation":[0-9.]*' | cut -d: -f2)

	if [[ -z "$rain" ]] || [[ "$rain" == "null" ]]; then
		return 1
	elif (($(echo "$rain > 0" | bc -l 2>/dev/null))); then
		return 0 # rain
	else
		return 1 # no rain
	fi
}

fem-time() {
	# all the time btw :)
	# so let's say at nigth (from 1:00 AM) ALL DAYYEES
	day=$(date | awk '{printf $1}')
	if [[ $(date +%H) -gt 1 ]] && [[ $(date +%H) -lt 5 ]]; then
		return 0
	else
		return 1
	fi
}

log-to-file() {
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo -e "\n[$(date)]\n WARNING: no information was given" >>$LOG_
	else
		local dir="$1"
		local header=""

		local curr_wall="$2" # if the default wall
		local -n arr=$3      # using the original array
		local msg="ERROR:NO MESSAGES WAS FOUND (hint: stop this instance and delete:
		/tmp/wallpaper_state.txt, /tmp/wallpaper_list.txt)"

		if [ "${#arr[@]}" -gt 0 ]; then   # check if the array is not empty
			msg=$(printf "%s\n" "${arr[@]}") # joined the array into a string
		fi
		echo -e "\n$header\n[$(date)]\nWallpapers Directory: "$dir"\nCurrent Wallpaper: "$curr_wall"\n$msg" >>"$LOG_"
	fi
}

init_wallpaper_list() {
	find "$1" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.webm" -o -iname "*.mp4" \) | shuf >"$LIST_FILE"
	echo "0" >"$STATE_FILE"
}

# init:
avg=0
last_run=0
WALL_DIR="$MR_WALL"
info=()
systemctl --user start Wallpapers.service

# check if the script is running and get the start run time
run_time=$(ps aux | grep .local/bin/changeWall.sh | awk 'NR==1 {print $9}')

while getopts "v" opt; do
	case "$opt" in
	v)
		avg=1
		;;
	*)
		echo "use -v to set it to the avg wallpaper"
		;;
	esac
done

if [ $avg == 1 ]; then
	WALL_DIR="$AVG_WALL"
	init_wallpaper_list "$AVG_WALL"
	info+=("The wallpaper is set to avg_wall to change it you need to terminate this instance and run another one without the -v option")

fi

[ ! -f "$LIST_FILE" ] || [ ! -s "$LIST_FILE" ] && init_wallpaper_list "$MR_WALL"

while true; do

	current_time=$(date +%s)
	if [ "$date_" != $(date +%d-%m-%y) ]; then
		date_=$(date +%d-%m-%y)
		LOG_="$HOME/.local/share/chwall/Wallpapers-$date_.log"
	fi
	# check if run_time is set
	if [[ -n $run_time ]]; then
		info+=("Start runnig at: $run_time")
		run_time=""
	fi
	# skip if the script execute with -v option (no wall dir change)
	if [ $avg == 0 ]; then
		# every hour
		if [ $((current_time - last_run)) -ge 3600 ]; then

			tm_day=$(timeofday)
			last_run=$current_time
			tmp_walldir="$WALL_DIR"
			info+=("Api call now next call in: $(date -d '+1 hour' +'%H:%M')")
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
			# check if the wallpaper directory change:
			if [ "$tmp_walldir" != "$WALL_DIR" ]; then
				info+=("New wallpaper directory: $(date +%H:%M)")
				info+=("Wallpapers list : /tmp/wallpaper_list.txt")
			fi
		fi
	fi

	current_index=$(cat "$STATE_FILE")
	total_files=$(wc -l <"$LIST_FILE")
	[ "$current_index" -ge "$total_files" ] && init_wallpaper_list "$WALL_DIR" && current_index=0
	next_line=$((current_index + 1))
	IMG=$(sed -n "${next_line}p" "$LIST_FILE")
	echo "$((current_index + 1))" >"$STATE_FILE"
	wall_exists=$(find "$WALL_DIR" -wholename "$IMG" | wc -l)
	if [[ $wall_exists -eq 0 ]]; then
		IMG="$DEFAULT_IMG"
		info+=("Using default image: $DEFAULT_IMG")
	fi

	info+=("Total wallpapers: $total_files")
	current_image=$(basename $IMG)
	caelestia wallpaper -f "$IMG" >/dev/null 2>&1 # set the wallpaper
	$(upscale.sh "$IMG")                          # check if the image is upscale (no need to check if the script exist or not)
	log-to-file $WALL_DIR $current_image info     # this call dose not create a copy so the function use the original array
	info=()                                       # reinit dso that array flush every time we log the info to file
	sleep 350

done
