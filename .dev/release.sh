#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

cd ..
git status
echo "Do you want to continue?[yn]"
read resp
[[ $resp = "n" || $resp = "N" ]] && exit 0


local version=""
while [[ -z $version ]]; do
	echo -n "version: "
	read version
done

local message=""
while [[ -z $message ]]; do
	echo -n "message: "
	read message
done

git tag -a "$version" -m "$message" && git push origin "$version" && git push github "$version"