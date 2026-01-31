#!/bin/bash

# list of paths to search for conf files
DIR=("$HOME/.config/"
	"$HOME/"
	"$HOME/.local/share/"
	"/etc/"
	"/usr/share/"
)

LIST_CONF=""

# check if command line is valid (exists) or not
check-cm() {
	if type -P "$1" >/dev/null 2>&1; then
		return
	else
		echo ""$1" not found"
		exit 1
	fi
}

print() {
	local nb=$(cat "$LIST_CONF" | wc -l)
	local msg=$1

	echo -e "$1"
	if [ "$nb" -lt 21 ]; then
		cat "$LIST_CONF" 2>/dev/null
	else
		head -n 20 "$LIST_CONF" 2>/dev/null
		echo -e "\nsee more: $LIST_CONF"
	fi
}

# get the config files and store them in a file (!this function can stop the script):
get-files() {
	local can_create_file=false
	local com="$1"
	for dir in "${DIR[@]}"; do
		res=$(find "$dir""$com" -type f -printf 'file:///%p\n' 2>/dev/null)
		if [ "$?" -ne 0 ]; then
			continue
		else
			if $can_create_file; then
				can_create_file=true # one time
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
	echo "Usage : fnc [options] command"
	echo "-h : disply help"
	echo "-r : restore the configuration files to a file"
	echo "-c : deep search for configurations files"
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
	can_restore=false
	search_command=false

	while getopts "rch" opt; do
		case "$opt" in
		r)
			can_restore=true
			;;
		c)
			search_command=true
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

	if [ -z "$com" ]; then
		echo "no command provide"
		exit 2
	fi

	if ! $search_command; then
		check-cm "$com"
	fi

	# set file name :
	LIST_CONF="/tmp/cm_name:$com.fnc"

	if $can_restore; then
		msg=$(restore)
	else
		if [ -f "$LIST_CONF" ]; then
			print "Aleardy have it (run -r to restore it)\n$msg"
			exit 0
		fi
	fi

	get-files "$com"
	print "$msg"

	exit 0
}

main "$@"
