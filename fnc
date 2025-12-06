#!/bin/bash

# list ofpath to search in dotfiles
DIR=("$HOME/.config/"
	"$HOME/"
	"/etc/"
	"/usr/share/" # themes
)

LIST_CONF="/tmp/cm_name:"$1".txt"

check_cm() {
	if command -v "$1" >/dev/null 2>&1; then
		return
	else
		echo ""$1" not found"
		exit 1
	fi
}

make_full_path() {
	for fl in $1; do
		local line="$3""$2"/"$fl"
		echo "$line" >>"$LIST_CONF" # put full path of the file
	done

}

main() {

	if [ -z "$1" ]; then
		exit 1
	fi

	com="$1"
	check_cm "$com"

	if [ -f "$LIST_CONF" ]; then
		cat /dev/null >"$LIST_CONF"
	else
		lc=$(touch "$LIST_CONF" /dev/null 2>&1)
		[ $? -ne 0 ] && echo "$lc" && exit 2
	fi

	for dir in "${DIR[@]}"; do
		res=$(ls "$dir""$com" 2>/dev/null)
		if [ "$?" -eq 2 ]; then
			continue
		else
			make_full_path "$res" "$com" "$dir"
		fi
	done

	if [ ! -s "$LIST_CONF" ]; then
		echo -e " "$com" : No configurations files found"
		exit 0
	else

		echo "Possible location are :"
		cat "$LIST_CONF"

	fi

	exit 0
}

main "$1"
