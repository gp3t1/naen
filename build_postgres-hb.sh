#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

DIR=./postgres-hb
REPO=gp3t1/postgres-hb
TAG="$( cat ./.version )-$( egrep '^FROM.*' $DIR/Dockerfile | awk -F ':' '{ print $2; }' )"

docker build -q "$*" -t "$REPO:$TAG" "$DIR" && echo "built $REPO:$TAG"