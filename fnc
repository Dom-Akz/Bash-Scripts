#!/usr/bin/env bash

#

# list of paths to search for conf files
declare -r DIR=(
	"$HOME/.config/"
	"$HOME/"
	"$HOME/.local/share/"
	"/etc/"
	"/usr/share/"
)

declare LIST_CONF="/tmp/cmd_name:"

# cut the commande from the file name
get-cm() {
	echo $(basename "$LIST_CONF" .fnc | cut -d':' -f2)
}

# check if command line is valid (exists) or not
check-cm() {
	echo "$1"
	if type -p "$(get-cm)" &>/dev/null; then
		return
	else
		echo "$(get-cm) not found! (try running with -c)"
		exit 1
	fi
}

# print all found files
print-files() {
	local nb=$(cat "$LIST_CONF" | wc -l)
	echo "Possible locations are:"
	if [ "$nb" -lt 11 ]; then
		cat "$LIST_CONF" 2>/dev/null
	else
		head -n 20 "$LIST_CONF" 2>/dev/null
		echo -e "\nsee more: $LIST_CONF"
	fi
}

# get the config files and store them in a file (!this function can stop the script):
get-files() {
	local com="$(get-cm)"
	local file_ext="$1"
	local res=""
	for dir in "${DIR[@]}"; do
		# edit this command to get better result
		res=$(find "$dir""$com""/" -name ".*" -prune -o -type f -printf 'file:///%p\n' 2>/dev/null)
		if [ "$?" -eq 1 ]; then
			continue
		else
			echo "$res" >>"$LIST_CONF"
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
	else
		# now last step filter for cleaner list
		filtre
	fi
}

#TODO: try to do this in just one grep-cut command
# delete non conf files (ex: images, videos, document, ...)
filtre() {
	local cm=$(get-cm)
	# create a new file
	touch /tmp/new_list-"$cm"
	for fl in $(cat "$LIST_CONF"); do
		$(echo "$fl" | grep -Eq ".png|.jpg|.jpeg|.webp|.gif|.mp3|.mp4|.pdf|.docx|.doc|.pptx")
		[[ ! $? -eq 0 ]] && echo $fl >>/tmp/new_list-"$cm" # now add the conf file to the new list
	done
	# now we cp the new list to the og
	cp /tmp/new_list-"$cm" "$LIST_CONF"
	rm /tmp/new_list-"$cm"
}

usage() {
	cat <<EOF
NAME
	find configurations files of a given name

USAGE : fnc [options] command

OPTIONS:
  -h : display help
  -r : restore the configuration files to a file
  -c : deep search for configuration files
  -m : only search for configuration files with most common extensions (does not support app-specific extensions)
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
# now add the conf file to the new list

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
			echo -e "Usage: fnc [OPTIONS]... NAME\nTry 'fnc -h' for more information."
			exit 1
			;;
		esac
	done

	shift $((OPTIND - 1))
	local com="$1"
	# set file name :
	LIST_CONF="$LIST_CONF$com.fnc"

	[[ -z "$com" ]] && {
		echo -e "Usage: fnc [OPTIONS]... NAME\nTry 'fnc -h' for more information."
		exit 1
	}

	if $can_restore; then
		restore
	else
		[[ -f "$LIST_CONF" ]] && {
			echo "Aleardy have it (run -r to restore it)"
			print-files
			exit 0
		}
	fi

	if ! $search_command && ! $can_restore; then
		check-cm
	fi

	get-files $use_cm_ext
	print-files
}

main "$@"
