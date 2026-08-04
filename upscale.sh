#!/usr/bin/env bash

image="$1"
res=$(exiftool "$image" | grep "Image Size" | cut -d: -f2)

x=$(echo "$res" | tr -d '[:space:]' | cut -dx -f1)
y=$(echo "$res" | tr -d '[:space:]' | cut -dx -f2)

if [ "$x" -lt 1960 ] && [ "$y" -lt 1080 ]; then
	notify-send -a Wallpapers -u normal "Image upscale"
fi
