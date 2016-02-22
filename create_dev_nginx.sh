#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

. ./run_dev_var.sh

NAME="naen-nginx"
TAG=$( ./build_nginx.sh | awk -F ' ' '{ print $2; }' )

docker rm -f -v "$NAME"
rm -rf $VOLUMES_DEV/$NAME/*
docker create --rm --name="$NAME" --net="$DOCKER_NET" --net-alias="$NAME" --hostname="$NAME" -v "$VOLUMES_DEV/$NAME/log:/var/log/nginx" -v "$VOLUMES_DEV/$NAME/www:/usr/share/nginx" -v "$VOLUMES_DEV/$NAME/config:/etc/nginx/conf.d" -v "/etc/letsencrypt:/etc/letsencrypt" -v "$VOLUMES_DEV/$NAME/backups:/backups" $TAG commafeed



