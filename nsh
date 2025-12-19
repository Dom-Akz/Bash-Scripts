#!/bin/bash

can_open=false

while getopts "nh" opt; do
	case "$opt" in
	n)
		can_open=true
		;;
	h)
		echo -e "Usage nsh filename [options]\n	-n : open file with vim"
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
	echo "no name was provide"
	exit 1
fi

if [ -f ".local/bin/$1" ]; then
	echo 'script name exists'
	exit 1
fi

touch .local/bin/"$1"

echo -e "#!/bin/bash" "\n echo 'script $1 created' " >>.local/bin/"$1"

chmod +x .local/bin/"$1"

if $can_open; then
	nvim /$HOME/.local/bin/"$1"
else
	"$1"
fi
