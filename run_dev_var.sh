#!/bin/bash

export DOCKER_NET=naen
export VOLUMES_DEV=./volumes

mkdir -p $VOLUMES_DEV

if ! docker network ls | awk '{ print $2 }' | grep -wq $DOCKER_NET; then
	docker network create "$network"
fi