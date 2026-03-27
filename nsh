#!/bin/bash

# create a executable script (default bash)

declare -r user=$(whoami)
declare -r sname='nsh'

declare LOCATION="$HOME"/.local/bin

declare -i OPEN=0

usage() {
	cat <<EOF
Usage ${sname} [options] filename

Options:
  -h, --help	displaydisplay this help
  -o, --open	open file in vim or neovim
  -l, --location	file location

Default Value:
  default directory is: /home/${user}/.local/bin/
  default file: bash
EOF
}

handle_ext() {
	local ext=$1
	local path=$2
	case "$ext" in
	'py')
		printf "print('script created')" >"$path"
		;;
	'c')
		echo -e '#include<stdio.h>\nint main(){\nprintf("script created");\nreturn 0;\n}' >"$path"
		;;
	'*')
		echo "[ExtentionError]: Unsupported extensions"
		exit 1
		;;
	esac
}

handle_file() {
	if [ -f "$1" ]; then
		echo "file exist! (try different name)"
		exit 1
	fi
	touch "$1"
	if [ $(ls -ld "$1" | awk '{print $3}') != "root" ]; then
		chmod +x "$1"
		bash "$1"
	else
		sudo chmod +x "$1"
		sudo bash "$1"
	fi
}

while getopts "ohl:" opt; do
	case "$opt" in
	o)
		OPEN=1
		;;
	l)
		LOCATION="$OPTARG""/"
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

filename="$1"

if [ -z "$filename" ]; then
	echo "no filename given"
	usage
	exit 1
fi

if [ ! -d $LOCATION ]; then
	echo "$LOCATION No such file or directory"
	exit 1
fi

ff="$LOCATION""$filename"
handle_file $ff

# check if the filename containe a extensions
printf "$filename" | grep "\.[a-zA-Z0-9]\+$" >/dev/null
if [ $? -eq 0 ]; then
	ext=$(printf "$filename" | cut -d'.' -f2) # extract the extensions
	handle_ext $ext $ff
else
	echo -e "#!/bin/bash" "\necho 'script created'" >"$ff"
fi

# check if neovim exist
if [ $OPEN -eq 1 ]; then
	if type -P nvim >/dev/null 2>&1; then
		nvim "$ff"
	else
		vim "$ff"
	fi
fi
