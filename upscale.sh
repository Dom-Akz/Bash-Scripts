#!/usr/bin/env bash

image="$1"
res=$(exiftool "$image" | grep "Image Size" | cut -d: -f2)
# TODO: fix cut error and cast to int
