#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

DIR="../docker_images/commafeed"
REPO="gp3t1/commafeed"
DEPLOY_SCRIPT="../deploy/deploy.sh"
DEV_COMPOSE="../deploy/docker-compose-dev.yml"
TAG="$( cat ./.version )-$( egrep '^ENV COMMAFEED_VERSION.*' $DIR/Dockerfile | awk -F ' ' '{ print $3; }' )"

if docker build -q "$@" -t "$REPO:$TAG" "$DIR"; then
	echo "built $REPO:$TAG"
	sed -i "s|image: ${REPO}:.*$|image: $REPO:$TAG|" "$DEV_COMPOSE"
	sed -i "s|^IMG_COMMAFEED=.*$|IMG_COMMAFEED=$REPO:$TAG|" "$DEPLOY_SCRIPT"
	exit 0
fi
exit 1
