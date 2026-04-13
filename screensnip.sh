#!/bin/bash

caelestia screenshot -r
filepath=$(zenity --file-selection --save --confirm-overwrite --title="save file as")

[[ -z "$filepath" ]] && exit 1

img=$(ls -t ~/.cache/caelestia/screenshots/ | head -n 1)
echo "$img"
mv ~/.cache/caelestia/screenshots/"$img" "$filepath"
