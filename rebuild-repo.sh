#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
DESTINATION="/var/www/reroll/repo"
RELEASES=$(curl -s https://api.github.com/repos/xtero/CrunchyREroll/releases |jq  -r .[].assets[0].name)
STORAGE="$SCRIPT_DIR/archive"

mkdir -p "$STORAGE"

for release in ${RELEASES[@]}; do
	if [ ! -e "$STORAGE/$release" ]; then
		echo "Downloading $release"
		version="v$(echo $release | awk -F '-' '{ print $2}' | rev | cut -c 5- | rev)"
		curl -L -s "https://github.com/xtero/CrunchyREroll/releases/download/$version/$release" -o $STORAGE/$release
	fi
	RELEASES_ARG="$STORAGE/$release $RELEASES_ARG"
done

$SCRIPT_DIR/create_repository.py -d $DESTINATION -z $RELEASES_ARG
