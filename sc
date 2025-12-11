#!/bin/bash

EXEC_PATH="$HOME/.config/hypr/custom/execs.conf"
SWITCH_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"

_exit() {
	read -p "reboot 0 shutdown 1 stop it now 2 : " ch

	case $ch in
	0)
		reboot
		;;
	1)
		shutdown now
		;;
	2)
		$(pkill -9 "changeWall.sh" 2>/dev/null)
		if [ $? -eq 1 ]; then
			echo "changeWall is not running"
			read -p "do you want to run it now [y/n] : " st
			[[ $st =~ ^[Yy]$ ]] && $(nohup changeWall.sh &) && exit 0
			exit 1
		else
			exit 0
		fi
		;;
	*)
		exit 1
		;;
	esac
}

echo_state() {
	if [ ! -z "$1" ]; then
		echo "Reverse v"
	else
		echo "Normal v"
	fi

	cat "$EXEC_PATH"
}

# REVERSE VERSION :

cat "$EXEC_PATH" | grep -qE '#'

if [ $? -eq 0 ]; then
	# UNCOMMENT AND JUMP TO _exit funciotn :
	sed -i '1s/^#//' "$EXEC_PATH"
	echo_state 1
	_exit
fi

# COMMENT THE exec-once COMMAND

sed -i '1s/^/#/' "$EXEC_PATH"
echo_state
# GET/SET THE PIC :

IMG_PATH=$(zenity --file-selection 2>/dev/null)

if [ -z "$(echo "$IMG_PATH" | grep -oE '.jpg|.jpeg|.png' 2>/dev/null)" ]; then
	echo "Imgae foramt invalid"
	exit 1
fi

bash "$SWITCH_SCRIPT" --image "$IMG_PATH" --mode dark --type auto >/dev/null 2>&1

_exit
