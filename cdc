#!/usr/bin/env bash

# get the exact change in disk space after adding or removing anything from /dev/nvme0n1p2
# edit the disk /dev/nvme0n1p2 to you're specifique device
# if the /tmp/cdc.txt change befor the second time you run the script it will not work

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
