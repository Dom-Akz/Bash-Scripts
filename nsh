#!/bin/bash

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

"$1"
