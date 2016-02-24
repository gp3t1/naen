#!/bin/bash

export DOCKER_NET=naen
export VOLUMES_DEV="/tmp/naen/volumes_dev"

if [[ ! -d "$VOLUMES_DEV" ]]; then
	sudo mkdir -p "$VOLUMES_DEV"
	sudo chmod 740 "$VOLUMES_DEV"
	sudo chown jeremy "$VOLUMES_DEV"
fi

if ! docker network ls | awk '{ print $2 }' | grep -wq $DOCKER_NET; then
	echo "Creating bridge network $DOCKER_NET"
	docker network create "$DOCKER_NET"
fi