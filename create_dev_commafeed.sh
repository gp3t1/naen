#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

. ./run_dev_var.sh

NAME="naen-commafeed"
TAG=$( ./build_commafeed.sh | awk -F ' ' '{ print $2; }' )

docker rm -f -v "$NAME"
rm -rf $VOLUMES_DEV/$NAME/*
docker create --rm --name="$NAME" --net="$DOCKER_NET" --net-alias="$NAME" --hostname="$NAME" -e PUBLIC_URL="https://docker-dev/rss" -e PG_URL="naen-postgres:5432/commafeed" -e USER="commafeed" -e PASSWORD="test" -v "$VOLUMES_DEV/$NAME/backups:/backups" -v "$VOLUMES_DEV/$NAME/config:/etc/commafeed" $TAG commafeed
