#!/bin/bash

DEV_COMPOSE="../deploy/docker-compose.yml"
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


sed -i "s|image: gp3t1/commafeed:.*$|image: gp3t1/commafeed:release-$version|
				s|image: gp3t1/postgres-hb:.*$|image: gp3t1/postgres-hb:release-$version|
				s|image: gp3t1/nginx:.*$|image: gp3t1/nginx:release-$version|" "$DEV_COMPOSE"
git add "$DEV_COMPOSE"
git commit -m "update images names in docker-compose"

git push && git push github master
git tag -a "$version" -m "$message" && git push origin "$version" && git push github "$version"