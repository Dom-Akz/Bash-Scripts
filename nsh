#!/bin/bash

if [ -z "$1" ]; then
	echo "no file was provide"
	exit 1
fi

if [ -f ".local/bin/$1" ]; then
	echo 'file exists'
	exit 1
fi

touch .local/bin/"$1"

echo -e "#!/bin/bash" "\n echo 'test' " >>.local/bin/"$1"

chmod +x .local/bin/"$1"
