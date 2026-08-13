#!/usr/bin/env bash

# calculate the change is disk (first run: current space disk, second run: print disk change)

file="/home/soufiane/.local/share/cdc.txt"

if [ ! -f "$file" ] || [ ! -s "$file" ]; then
	prev=$(df -B M /dev/nvme0n1p2 | awk '{printf $3}' | tr -d -c '0-9')
	echo "$prev" >$file
else
	curr=$(df -B M /dev/nvme0n1p2 | awk '{printf $3}' | tr -d -c '0-9')
	prev=$(cat $file)
	res=$((curr - prev))
	res=1002
	if [ $res -gt 1000 ]; then
		res=$((res / 1000))
		printf "change in disk is: %'dG" $res
	else
		printf "change in disk space is: %'dM" "$res"
	fi
	rm "$file"
fi
