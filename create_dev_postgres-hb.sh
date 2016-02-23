#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

. ./run_dev_var.sh

NAME="naen-postgres"
TAG=$( ./build_postgres-hb.sh | awk -F ' ' '{ print $2; }' )

docker rm -f -v "$NAME"
sudo rm -rf $VOLUMES_DEV/$NAME/*
docker create --name="$NAME" --net="$DOCKER_NET" --net-alias="$NAME" --hostname="$NAME" -e LANG="fr_FR.UTF-8" -e AREA="Europe" -e ZONE="Paris" -e POSTGRES_PASSWORD="test" -v "$VOLUMES_DEV/$NAME/backups":"/backups" -v "$VOLUMES_DEV/$NAME/pgdata":"/var/lib/postgresql/data" $TAG postgres
[[ $? ]] &&	echo "Successfully create container $NAME" && exit 0 || exit 1