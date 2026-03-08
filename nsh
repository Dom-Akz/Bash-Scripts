#!/bin/bash

# create a executable bash script
# with option -n : open script in vim (use the same session)
DEF_DIR="/$HOME/.local/bin/"

can_open=false
location="$DEF_DIR"
while getopts "nhl:" opt; do
	case "$opt" in
	n)
		can_open=true
		;;
	l)
		location="$OPTARG""/"
		;;
	h)
		echo -e "Default directory is: /home/$(whoami)/.local/bin/
			\nUsage nsh filename [options]
			\n-n :open file with neovim\n-l :file location"
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
	exit 1
fi

ff="$location""$1"

if [ -f "$ff" ]; then
	echo 'script name exists'
	exit 1
fi

touch $ff
echo -e "#!/bin/bash" "\n echo 'script $1 created' " >>"$ff"
chmod +x "$ff"

if $can_open; then
	if type -P nvim >/dev/null 2>&1; then
		nvim "$ff"
	else
		vim "$ff"
	fi
fi
