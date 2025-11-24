#!/bin/bash
checkpodman(){
    echo $(command -v podman)
}
checkdocker(){
    echo $(command -v docker)
}

if [ ! -f .env ]; then
    if [ ! -f .env.dist ]; then
        echo "No .env or .env.dist file found. Please ensure you run this script from the correct directory!"
        exit 1
    else
        cp .env.dist .env
    fi
fi
git restore .env.dist
source .env

ORCH=podman

if [ ! -z "${CONTAINER_ORCHESTRATOR}" ]; then
    ORCH="${CONTAINER_ORCHESTRATOR}"
else
    if [ ! $(checkpodman) ]; then
        if [ ! $(checkdocker) ]; then
            echo "No Container-Orchestrator found."
            exit 1
        else
            ORCH=docker
        fi
    fi
fi

COMPOSE_COMMAND="podman compose"

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
