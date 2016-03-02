#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

TAG=$( ./build_commafeed.sh "--no-cache=false" | awk -F ' ' ' $1=="built" { print $2; }' )

docker push "$TAG"