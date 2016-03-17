#!/bin/bash

DEV_COMPOSE="../deploy/docker-compose.yml"
SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

function getc {
  IFS= read -r -n1 -d '' "$@"
}

git status
echo -en "\nDo you want to continue?[yn]"
getc resp
[[ $resp = "n" || $resp = "N" ]] && exit 0


while [[ -z $version ]]; do
	echo -en "\nversion: "
	read version
done

while [[ -z $message ]]; do
	echo -en "\nmessage: "
	read message
done

echo -e "\nUpdate images version in $DEV_COMPOSE..."
sed -i "s|image: gp3t1/commafeed:.*$|image: gp3t1/commafeed:release-$version|
				s|image: gp3t1/postgres-hb:.*$|image: gp3t1/postgres-hb:release-$version|
				s|image: gp3t1/nginx:.*$|image: gp3t1/nginx:release-$version|" "$DEV_COMPOSE"

echo "Commit changes in $DEV_COMPOSE..."
git add "$DEV_COMPOSE"
git commit -m "update images version in docker-compose"

echo "Pushing all branches to origin and only master to gitub..."
git push && git push github master

echo "Tagging actual state with $version and push tag to origin and github"
git tag -a "$version" -m "$message" && git push origin "$version" && git push github "$version"

echo "Revert images version in $DEV_COMPOSE to latest (workdir only, not committed)..."
sed -i "s|image: gp3t1/commafeed:.*$|image: gp3t1/commafeed:latest|
				s|image: gp3t1/postgres-hb:.*$|image: gp3t1/postgres-hb:latest|
				s|image: gp3t1/nginx:.*$|image: gp3t1/nginx:latest|" "$DEV_COMPOSE"