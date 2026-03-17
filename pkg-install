#!/bin/bash

# Fake package install simulator with progress bar
# Usage: ./fake-install.sh -d <minutes> -s <size> -v <version> <package-name>

# Function to simulate a delay with progress bar
progress_delay() {
	local total_seconds=$1
	local message=${2:-"Processing"}
	local bar_width=50
	local update_interval=0.1

	local steps=$((total_seconds * 10))
	local current_step=0

	echo -ne "\e[s"

	while [ $current_step -le $steps ]; do
		percentage=$((current_step * 100 / steps))
		filled=$((current_step * bar_width / steps))

		bar=""
		for ((i = 0; i < bar_width; i++)); do
			if [ $i -lt $filled ]; then
				bar="${bar}#"
			else
				bar="${bar}-"
			fi
		done

		echo -ne "\e[u\e[K$message: [$bar] $percentage%"

		current_step=$((current_step + 1))
		sleep $update_interval
	done

	echo ""
}

# Function to show usage
show_usage() {
	echo "Usage: pkg-install -d <minutes> -s <size> -v <version> <package-name>"
	echo "  -d : delay in minutes"
	echo "  -s : package size (e.g., 0.05, 1.2, 15.7)"
	echo "  -v : package version (e.g., 1.234_1, 2.0.1, 1.5.3-2)"
	echo "  package-name : name of the package (without version)"
	exit 1
}

# Parse arguments
while getopts "d:s:v:" opt; do
	case $opt in
	d)
		DELAY_MINUTES=$OPTARG
		;;
	s)
		PACKAGE_SIZE=$OPTARG
		;;
	v)
		PACKAGE_VERSION=$OPTARG
		;;
	\?)
		show_usage
		;;
	esac
done

shift $((OPTIND - 1))
PACKAGE_NAME=$1

if [ -z "$DELAY_MINUTES" ] || [ -z "$PACKAGE_SIZE" ] || [ -z "$PACKAGE_VERSION" ] || [ -z "$PACKAGE_NAME" ]; then
	show_usage
fi

DELAY_SECONDS=$((DELAY_MINUTES * 60))
FULL_PACKAGE_NAME="${PACKAGE_NAME}-${PACKAGE_VERSION}"

clear

echo "Sync Explicit (1): $FULL_PACKAGE_NAME"
echo "[sudo] password for soufiane: "
sleep 1

progress_delay 2 "resolving dependencies"
echo "looking for conflicting packages..."
progress_delay 2 "looking for conflicting packages"

echo ""
echo "Packages (1) $FULL_PACKAGE_NAME"
echo ""
echo "Total Installed Size:  ${PACKAGE_SIZE} MiB"
echo "Net Upgrade Size:      0.00 MiB"
echo ""
echo -n ":: Proceed with installation? [Y/n] "
read -r response
if [[ "$response" =~ ^[Nn]$ ]]; then
	echo "Installation cancelled."
	exit 0
fi

echo ""
echo "(1/1) checking keys in keyring"
progress_delay 1 "checking keys in keyring"
echo "(1/1) checking package integrity"
progress_delay 1 "checking package integrity"
echo "(1/1) loading package files"
progress_delay 1 "loading package files"
echo "(1/1) checking for file conflicts"
progress_delay 1 "checking for file conflicts"
echo "(1/1) checking available disk space"
progress_delay 1 "checking available disk space"
echo ":: Processing package changes..."
echo ""
echo "(1/1) installing $PACKAGE_NAME"
progress_delay $DELAY_SECONDS "installing $PACKAGE_NAME"

echo ":: Running post-transaction hooks..."
progress_delay 1 "Running post-transaction hooks"
echo "(1/1) Arming ConditionNeedsUpdate..."

echo ""
