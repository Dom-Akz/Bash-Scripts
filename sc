#!/bin/bash

EXEC_CMD="#exec-once = ~/.local/bin/changeWall.sh"
FILE_PATH="$HOME/.config/hypr/custom/execs.conf"
SWITCH_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"

# GET/SET THE PIC PATH  :

IMG_PATH=$(zenity --file-selection 2>/dev/null)

ext=$(echo "$IMG_PATH" | grep -oE '.jpg|.jpeg|.png')

if [ -z "$ext" ]; then
	echo "Imgae foramt invalid"
	exit
fi

bash "$SWITCH_SCRIPT" --image "$IMG_PATH" --mode dark --type auto >/dev/null 2>&1

# COMMENT THE exec-once COMMAND

echo "$EXEC_CMD" >"$FILE_PATH"

read -p "reboot 0 or shutdown 1 : " ch

case $ch in
0)
	reboot
	;;
1)
	shutdown
	;;
*)
	exit
	;;
esac
