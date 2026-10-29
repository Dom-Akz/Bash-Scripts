#!/usr/bin/env bash

DIR="$HOME/Music/Record/"

[[ ! -d $DIR ]] && exit 1

size=0
n_size=0

set_size() {
	size=$(du -sb $DIR | awk '{print $1}')
	n_size=$((size - n_size))
}

while :; do
	set_size
	[[ $n_size -gt $((100 * 1024 ** 2)) ]] && notify-send -u critical "$DIR grew by more than 100 MB"
	[[ $size -ge $((1024 ** 3)) ]] && { # dir reach 1G
		notify-send -u critical "$DIR is $((size / 1024 ** 3))G" "max size reache, closing the service..."
		systemctl --user stop arec.service
	}
	sleep 350
done
