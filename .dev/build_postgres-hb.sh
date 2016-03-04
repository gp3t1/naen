#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

DIR="../postgres-hb"
REPO="gp3t1/postgres-hb"
DEPLOY_SCRIPT="../deploy.sh"
TAG="$( cat ./.version )-$( egrep '^FROM.*' $DIR/Dockerfile | awk -F ':' '{ print $2; }' )"

if docker build -q "$@" -t "$REPO:$TAG" "$DIR"; then
	echo "built $REPO:$TAG"
	sed -i "s|^IMG_POSTGRES=.*$|IMG_POSTGRES=$REPO:$TAG|" "$DEPLOY_SCRIPT"
	exit 0
fi

exit 1