#!/usr/bin/env bash

# calculate the change is disk (first run: current space disk, second run: calculate disk change)
# edit the disk /dev/nvme0n1p2 to you're specifique device

file="/home/soufiane/.local/share/cdc.txt"

if [ ! -f "$file" ] || [ ! -s "$file" ]; then
	prev=$(df -B M /dev/nvme0n1p2 | awk '{printf $3}' | tr -d -c '0-9')
	echo "$prev" >$file
else
	curr=$(df -B M /dev/nvme0n1p2 | awk '{printf $3}' | tr -d -c '0-9')
	prev=$(cat $file)
	res=$((curr - prev))
	printf "change in disk space is: %'dM" "$res"
	rm "$file"
fi
