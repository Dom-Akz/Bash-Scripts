#!/usr/bin/env bash

# path to the log file
log="/home/soufiane/.local/share/chwall/Wallpapers-$(date +%d-%m-%y).log"
nb=0

while inotifywait -e modify "$log"; do
	# only getting once in this condition every first time the scrtipt is running
	if [ "$nb" -eq 0 ]; then
		msg=$(grep -Eni 'ERROR|Warning' "$log")
		if ! [ -z "$msg" ]; then
			nb=$(echo "$msg" | cut -d: -f1 | tail -n 1)                               # set the number of last error line
			cn=$(echo "$msg" | wc -l)                                                 # nombers of errors
			msg=$(echo "$msg" | cut -d: -f2 | head -n 1)                              # get the first error message
			notify-send -a Wallpapers -u normal "$msg"                                # send error notif
			notify-send -a Wallpapers -u low "There is $cn more error check log $log" # send info notif
		fi
	fi

	if [ "$nb" != 0 ]; then
		is_notfiy=0
		for line in $(grep -Eni "ERROR|Warning" "$log"); do
			new_nb=$(echo "$line" | cut -d: -f1)

			# start searching from here for any new errors
			if [ "$nb" -lt "$new_nb" ]; then
				nb="$new_nb"
				if [ "$is_notfiy" -eq 0 ]; then
					msg=$(echo "$line" | cut -d: -f2)
					notify-send -a Wallpapers -u normal "$msg"
					is_notfiy=1
				fi
			fi
		done
	fi

done
