#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

DIR="../docker_images/nginx"
REPO="gp3t1/nginx"
DEPLOY_SCRIPT="../deploy/deploy.sh"
TAG="$( cat ./.version )-$( egrep '^FROM.*' $DIR/Dockerfile | awk -F ':' '{ print $2; }' )"

if docker build -q "$@" -t "$REPO:$TAG" "$DIR"; then
	echo "built $REPO:$TAG"
	sed -i "s|^IMG_NGINX=.*$|IMG_NGINX=$REPO:$TAG|" "$DEPLOY_SCRIPT"
	exit 0
fi
exit 1
