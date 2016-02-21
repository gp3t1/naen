#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

DIR=./commafeed
REPO=gp3t1/commafeed
TAG="$( cat ./.version )-$( egrep '^ENV COMMAFEED_VERSION.*' $DIR/Dockerfile | awk -F ' ' '{ print $3; }' )"

docker build -q "$*" -t "$REPO:$TAG" "$DIR" && echo "built $REPO:$TAG"
