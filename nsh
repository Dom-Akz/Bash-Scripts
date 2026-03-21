#!/bin/bash

# create a executable bash script
# with option -n : open script in nvim/vim
DIR="$HOME/.local/bin/"

user=$(whoami)

usage() {
	echo -e "Usage nsh [options] filename
			\n-h:display this help\n-n: open file with neovim\n-l: file location"
	echo -e "Default Value:
			\ndefault directory is: /home/"$user"/.local/bin/
			\ndefault extenstion: .sh (bash)"
}

handle_ext() {
	local ext=$1
	local fn=$2
	local path=$3
	case "$ext" in
	".py")
		echo "print("$fn created")" >$path
		;;
	".c")
		echo -e "include<stdio.h>\nprintf("$fn created")" >$path
		;;
	"*")
		echo "[ExtentionError]: Unsupported extenstion"
		exit 1
		;;
	esac
}

can_open=false
location="$DIR"
while getopts "nhl:" opt; do
	case "$opt" in
	n)
		can_open=true
		;;
	l)
		location="$OPTARG""/"
		;;
	h)
		usgae
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

if [ -z "$1" ]; then
	echo "no filename given"
	usage
	exit 1
fi

if [ -f "$ff" ]; then
	echo 'script name exists'
	exit 1
fi

ff="$location""$1" # this is the path/file
if [ $(ls -ld "$location" | awk '{print $3}') != "root" ]; then
	touch "$ff"
	chmod +x "$ff"
else
	sudo touch "$ff"
	sudo chmod +x "$ff"
fi

# check if the filename containe a extention
echo "$1" | grep "\.[a-zA-Z0-9]\+$" 2>/dev/null
if [ $? -eq 0 ]; then
	ext=$(echo "$1" | cut -d'.' -f2) # extract the file extenstion
	handle_ext $ext $1 $ff
else
	echo -e "#!/bin/bash" "\necho 'script $1 created'" >"$ff"
fi

# check if neovim exist
if $can_open; then
	if type -P nvim >/dev/null 2>&1; then
		nvim "$ff"
	else
		vim "$ff"
	fi
fi
