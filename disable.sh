#!/usr/bin/env bash

disable-usb() {
	for usb in $(find /sys/bus/usb/devices/ -name "*usb*"); do
		echo "0" | sudo tee "$usb/authorized"
	done
}

disable-hdmi() {
	# check if the hdmi is active
	for hdmi in $(find /sys/class/drm/ -name "*HDMI*"); do
		res=$(cat "$hdmi/status")
		if [ $res == "connected" ]; then
			hdmiPort=$(basename "$hdmi" | sed 's/^card[0-9]-//')
			xrandr --output "$hdmiPort" --off 2>/dev/null
			return 0 # only one file is enabled (connected)
		fi
	done
	return 1
}

disable-usb
[[ $? -eq 1 ]] && echo "Error durning usb port disabling"

disable-hdmi
[[ $? -eq 1 ]] && echo "Warning:No HDMI output is connected"
