#!/bin/sh
checkpodman(){
    command -v podman
}
checkdocker(){
    command -v docker
}
checkgit(){
    command -v git
}
checksqlite(){
    command -v sqlite3
}
checkwget(){
    command -v wget
}
checkunzip(){
    command -v unzip
}

if [ ! -f .env ]; then
    if [ ! -f .env.dist ]; then
        echo "No .env or .env.dist file found. Please ensure you run this script from the correct directory!"
        exit 1
    else
        cp .env.dist .env
    fi
fi
if [ "$(checkgit)" ]; then
    git restore .env.dist
fi
. ./.env

export ORCH=podman

if [ ! -z "${CONTAINER_ORCHESTRATOR}" ]; then
    ORCH="${CONTAINER_ORCHESTRATOR}"
    if [ ! "$(checkpodman)" ]; then
        if [ ! "$(checkdocker)" ]; then
            if [ -z "$INSIDE_CONTAINER" ]; then # Only an error case if ran outside of the container.
                echo "No Container-Orchestrator found."
                exit 1
            fi
        else
            ORCH=docker
        fi
    fi
fi

export COMPOSE_COMMAND="podman compose"

if [ ! -z "${CONTAINER_COMPOSER}" ]; then
    COMPOSE_COMMAND="$CONTAINER_COMPOSER"
else
    if [ "$ORCH" = "docker" ]; then
        COMPOSE_COMMAND="docker compose"
    fi
    if [ ! -z "${CONTAINER_ORCHESTRATOR}" ]; then
        COMPOSE_COMMAND="$CONTAINER_ORCHESTRATOR-compose"
    fi
fi
