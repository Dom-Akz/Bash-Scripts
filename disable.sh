#!/bin/env bash

# use the /sys
disable-usb() {
	for usb in $(find /sys/bus/usb/devices/ -name "*usb*"); do
		local location="$usb/authorized"
		echo "0" | sudo tee "$location"
	done
}

# use class/drm
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

main() {

	#initilaize the pci bus :
	#echo '1' | sudo tee /sys/bus/pci/resan

	#com=$(lspci | grep -E "USB|Audio|VGA|HDMI|Display|Ethernet|Network|Thunderbolt|FireWire|IEEE 1394
	#|Serial Port|Parallel Port|eSATA|Card Reader|Modem|Bluetooth|WiFi|WLAN|Graphics|3D|Video")
	disable-usb

	disable-hdmi
	if [ $? -eq 1 ]; then
		echo "warning:No HDMI output is connected"
	fi
}

main "$@"
