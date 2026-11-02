#!/usr/bin/env bash

# WATCH DIR SIZE CHANGE ON DISK (I USE THIS FOR VOIC RECORDING)

DIR="$HOME/Music/Record/"
[[ ! -d $DIR ]] && exit 1

size=0
n_size=0

while :; do
	size=$(du -sb $DIR | awk '{print $1}')
	n_size=$((size - n_size))
	[[ $n_size -gt $((100 * 1024 ** 2)) ]] && notify-send -u critical "$DIR grew by more than 100 MB"
	if [[ $size -ge $((1024 ** 3)) ]]; then # dir reach 1G
		notify-send -u critical "$DIR is $((size / 1024 ** 3))G" "max size reache, closing the service..."
		systemctl --user stop arec.service
	fi
	sleep 350
	if [[ ! -d $DIR ]]; then
		notify-send -u critical "$DIR was removed during the service execution" "the arec.service is likely failed"
		exit 1
	fi
done
