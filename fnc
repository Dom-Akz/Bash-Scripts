#!/usr/bin/env bash

# list of paths to search for conf files
declare -r DIR=(
	"$HOME/.config/"
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

# print all found files
print-files() {
	local nb=$(cat "$LIST_CONF" | wc -l)
	local msg=$1
	echo -e $msg
	if [ "$nb" -lt 11 ]; then
		cat "$LIST_CONF" 2>/dev/null
	else
		head -n 20 "$LIST_CONF" 2>/dev/null
		echo -e "\nsee more: $LIST_CONF"
	fi
}

# get the config files and store them in a file (!this function can stop the script):
get-files() {
	local com="$1"
	local file_ext="$2"
	local res=""
	for dir in "${DIR[@]}"; do
		# edit this command to get better result
		res=$(find "$dir""$com""/" -name ".*" -prune -o -type f -printf 'file:///%p\n' 2>/dev/null)
		if [ "$?" -eq 1 ]; then
			continue
		else
			echo "$res" >>$LIST_CONF
			res=""
		fi
	done
	# we can stop here if file is empty
	if [[ ! -s "$LIST_CONF" ]]; then
		echo "$com : No configurations files found"
		exit 0
	fi
	# if flag m is set
	if $file_ext; then
		cp $LIST_CONF "/tmp/tmp-$com"
		cat "/tmp/tmp-$com" | grep -E ".conf|.config|.toml|.json|.sjson" >"$LIST_CONF"
		rm "/tmp/tmp-$com" 2>/dev/null
	fi
}

# delete non conf files (ex: images, videos, document, ...)
# filtre(){}

usage() {
	cat <<EOF
Usage : fnc [options] command

Options:
  -h : display help
  -r : restore the configuration files to a file
  -c : deep search for configuration files (for more specifique search use -m insted)
  -m : only search for configuration files with most common extensions (does not support application-specific extensions)
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
	local can_restore=false
	local search_command=false
	local use_cm_ext=false

	while getopts "rcmh" opt; do
		case "$opt" in
		r)
			can_restore=true
			;;
		c)
			search_command=true
			;;
		m)
			use_cm_ext=true
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

	if $can_restore; then
		msg=$(restore)
	else
		if [ -f "$LIST_CONF" ]; then
			print-files "Aleardy have it (run -r to restore it)\n$msg"
			exit 0
		fi
	fi

	if ! $search_command && ! $can_restore; then
		check-cm "$com"
	fi

	get-files $com $use_cm_ext
	print-files $msg
}

main "$@"
