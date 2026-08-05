#!/usr/bin/env bash

# monitor a log file and send notifications if any new error occur in log

# path to the log file (if the path is worng inotifywait will raise the error)
log="/home/soufiane/.local/share/chwall/Wallpapers-$(date +%d-%m-%y).log"

nb=0 # hold the last error line number

while inotifywait -e modify "$log"; do
	# only getting once in this condition every time the scrtipt is running
	if [ "$nb" -eq 0 ]; then
		msg="$(grep -Eni 'Error|err|warn|exception|fatal|Warning' "$log")"
		if ! [ -z "$msg" ]; then
			nb=$(echo "$msg" | cut -d: -f1 | tail -n 1)
			# set the number of last error line
			cn=$(echo "$msg" | wc -l)                                                                    # nombers of errors
			msg=$(echo "$msg" | cut -d: -f2 | head -n 1)                                                 # get the first error message
			notify-send -a Wallpapers -u normal "$msg"                                                   # send the first error occur in the file
			[[ $cn -gt 1 ]] && notify-send -a Wallpapers -u low "There is $cn more error check log $log" # send info notif of how much error in the file
		fi

	elif [ "$nb" != 0 ]; then
		is_notfiy=0
		while read -r line; do
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
		done <"$log"
	fi
done
