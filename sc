#!/bin/bash

FILE_PATH="$HOME/.config/hypr/custom/execs.conf"
SWITCH_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"

_exit() {
	read -p "reboot 0 or shutdown 1 : " ch

	case $ch in
	0)
		reboot
		;;
	1)
		shutdown now
		;;
	*)
		exit 1
		;;
	esac
}

# REVERSE VERSION :

cat "$FILE_PATH" | grep -qE '#'

if [ $? -eq 0 ]; then
	# UNCOMMENT AND JUMP TO _exit funciotn :
	sed -i '1s/^#//' "$FILE_PATH"
	_exit
fi

# COMMENT THE exec-once COMMAND

sed -i '1s/^/#/' "$FILE_PATH"

# GET/SET THE PIC :

IMG_PATH=$(zenity --file-selection 2>/dev/null)

if [ -z "$(echo "$IMG_PATH" | grep -oE '.jpg|.jpeg|.png' 2>/dev/null)" ]; then
	echo "Imgae foramt invalid"
	exit 1
fi

bash "$SWITCH_SCRIPT" --image "$IMG_PATH" --mode dark --type auto >/dev/null 2>&1

_exit
