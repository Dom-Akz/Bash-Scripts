#!/bin/bash

# list ofpath to search in dotfiles
DIR=("$HOME/.config/"
	"$HOME/"
	"/etc/"
	"/usr/share/" # themes
)

LIST_CONF="/tmp/cm_name:"$1".txt"

check-cm() {
	if type -P "$1" >/dev/null 2>&1; then
		return
	else
		echo ""$1" not found"
		exit 1
	fi
}

#get-package-name() {}

main() {

	restore="false"

	while [ $# -gt 0 ]; do
		case "$1" in
		-r)
			restore="true"
			;;
		*) ;;
		esac
	done

	if [ -z "$1" ]; then
		echo "no command provide"
		exit 2
	else
		local com="$1"
		check-cm "$com"
	fi

	# if file exists then must be not empty

	if [ -f "$LIST_CONF" ] && [ "$restore" == "true" ]; then
		echo -e "Aleardy have it (run -r to restore it)\nPossible location are :\n"
		cat "$LIST_CONF"
		exit 0
	else
		echo $(cat /dev/null) >>"$LIST_CONF"
	fi
	local can_create_file=false

	for dir in "${DIR[@]}"; do
		res=$(find "$dir""$com" -type f -printf 'file:///%p\n' 2>/dev/null)
		if [ ! "$?" -eq 0 ]; then
			continue
		else
			if [ "$can_create_file" == "flase" ]; then
				can_create_file=true # one time
				lc=$(touch "$LIST_CONF" /dev/null 2>&1)
				[ $? -ne 0 ] && echo "$lc" && exit 2 # in case any error
			fi

			echo "$res" >>"$LIST_CONF"
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
