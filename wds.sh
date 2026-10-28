#!/usr/bin/env bash

DIR="$HOME/Music/Record/"

[[ ! -d $DIR ]] && exit 1

size=0
n_size=0

set_size() {
	size=$(du -sm $DIR | cut -f1)
	n_size=$((size - n_size))
}

while :; do
	set_size
	[[ $n_size -gt 100 ]] && notify-send -u critical "$DIR grew by more than 100 MB"
	sleep 350
done
