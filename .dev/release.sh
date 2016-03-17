#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

cd ..
git status
echo "Do you want to continue?[yn]"
read resp
[[ $resp = "n" || $resp = "N" ]] && exit 0


while [[ -z $version ]]; do
	echo -n "version: "
	read version
done

while [[ -z $message ]]; do
	echo -n "message: "
	read message
done
git push && git push github master
git tag -a "$version" -m "$message" && git push origin "$version" && git push github "$version"