#!/usr/bin/env bash

image="$1"
res=$(exiftool "$image" | grep "Image Size" | cut -d: -f2)
echo "$res"
x=$(echo "$res" | tr -d '[:space:]' | cut -dx -f1)
echo "$x"
