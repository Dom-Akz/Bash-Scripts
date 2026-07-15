#!/usr/bin/env bash

# path to the log file
log="/home/soufiane/.local/share/chwall/wallpapers-$(date +%d-%m-%y).log"

# number of the last error that has been notify
nb=0

while inotifywait -e modify "$log"; do
	msg=""
	# get only the new lines (nombre des lignes ajouter)
	msg=$(tail -n (number of line add to file starting from the nb var) "$log" | grep -En 'ERROR|Warning') # get only the firt error
	if ! [ -z "$msg" ]; then
		nb=$(echo "$msg" | cut -d: -f1 | head -n 1) # set the number of first error line
		cn=$(echo "$msg" | wc -l)                   # nb all error
		notify-send "$msg"
		notify-send "There is $cn more error check log $log"
	fi
done
