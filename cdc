#!/usr/bin/env bash

file="/tmp/cdc.txt"

if ! [ -f "$file" ]; then
	prev=$(df -B M /dev/nvme0n1p2 | awk '{printf $3}' | tr -d -c '0-9')
	echo "$prev" >$file
else
	curr=$(df -B M /dev/nvme0n1p2 | awk '{printf $3}' | tr -d -c '0-9')
	prev=$(cat $file)
	add=$((curr - prev))
	printf "added space is: %'dM" "$add"
	rm "$file"
fi
