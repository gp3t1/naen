#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
cd "$SCRIPT_PATH"

find ../ -name "*.sh" -exec shellcheck {} \;