#!/bin/sh
. ./preamble.sh

if [ ! -z "$INSIDE_CONTAINER" ]; then
    echo "Already inside container"
    exit 1
fi

$COMPOSE_COMMAND run --rm -w '/repo' -v ".:/repo" --entrypoint "/bin/bash" mangosd
