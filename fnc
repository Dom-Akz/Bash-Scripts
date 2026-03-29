#!/bin/bash

# list of paths to search for conf files
DIR=("$HOME/.config/"
	"$HOME/"
	"$HOME/.local/share/"
	"/etc/"
	"/usr/share/"
)

declare LIST_CONF="/tmp/cmd_name:"

# check if command line is valid (exists) or not
check-cm() {
	if type -P "$1" >/dev/null 2>&1; then
		return
	else
		echo "$1 not found! (try running with -c)"
		exit 1
	fi
}

print() {
	local nb=$(cat "$LIST_CONF" | wc -l)
	local msg=$1

	echo -e $msg # -e, msg have \n
	if [ "$nb" -lt 11 ]; then
		cat "$LIST_CONF" 2>/dev/null | bat -l txt --file-name "$LIST_CONF"
	else
		head -n 20 "$LIST_CONF" 2>/dev/null | bat -l txt --file-name "$LIST_CONF"
		echo -e "\nsee more: $LIST_CONF"
	fi
}

# get the config files and store them in a file (!this function can stop the script):
get-files() {
	local can_create_file=0
	local com="$1"
	for dir in "${DIR[@]}"; do
		res=$(find "$dir""$com" -type f -printf 'file:///%p\n' 2>/dev/null)
		if [ "$?" -eq 1 ]; then
			continue
		else
			if [[ $can_create_file -eq 1 ]]; then
				can_create_file=0 # one time
				lc=$(touch $LIST_CONF /dev/null 2>&1)
				[ $? -ne 0 ] && echo "$lc" && exit 2 # in case any error
			fi

			echo "$res" >>$LIST_CONF
		fi
	done
	# we can stop here if file is empty
	if [[ ! -s "$LIST_CONF" ]]; then
		echo "$com : No configurations files found"
		exit 0
	fi
}

usage() {
	cat <<EOF
Usage : fnc [options] command
-h : display help
-r : restore the configuration files to a file
-c : deep search for configuration files
EOF
}

restore() {
	if [ -f "$LIST_CONF" ]; then
		rm "$LIST_CONF" 2>/dev/null # delete the file and in get_files function it will be created
		echo "File restored successfully."
	else
		echo "Warning: file not found. Nothing has been restored."
	fi
}

main() {
	# init :
	declare -i can_restore=0
	declare -i search_command=0

	while getopts "rch" opt; do
		case "$opt" in
		r)
			can_restore=1
			;;
		c)
			search_command=1
			;;
		h)
			usage
			exit 0
			;;
		\*)
			echo "invalid option -$opt"
			usage
			exit 1
			;;
		esac
	done

	shift $((OPTIND - 1))
	local com="$1"
	local msg="Possible locations are:"
	# set file name :
	LIST_CONF="$LIST_CONF$com.fnc"

	if [ -z "$com" ]; then
		echo "no command provide"
		usage
		exit 2
	fi

	if [ $can_restore -eq 1 ]; then
		msg=$(restore)
	else
		if [ -f "$LIST_CONF" ]; then
			print "Aleardy have it (run -r to restore it)\n$msg"
			exit 0
		fi
	fi

	if [ $search_command -eq 0 ] && [ $can_restore -eq 0 ]; then
		check-cm "$com"
	fi

	get-files "$com"
	print "$msg"
}

main "$@"
