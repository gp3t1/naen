#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

DIR=../commafeed
REPO=gp3t1/commafeed
TAG="$( cat ./.version )-$( egrep '^ENV COMMAFEED_VERSION.*' $DIR/Dockerfile | awk -F ' ' '{ print $3; }' )"

if docker build -q "$@" -t "$REPO:$TAG" "$DIR"; then
	echo "built $REPO:$TAG"
	exit 0
fi
exit 1
