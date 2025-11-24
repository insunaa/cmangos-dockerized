#!/bin/sh
# shellcheck disable=SC3045
if [ ! -s .env ]; then
    echo "Please modify the '.env' file to select the desired expansion!"
    cp .env.dist .env
    exit 1
fi

. ./preamble.sh

if [ ! -z "$INSIDE_CONTAINER" ]; then
    echo 'Setup cannot be done from inside the container. Please build it regularly.'
    exit 1
fi

if [ "$#" -lt 1 ]; then
    echo 'Usage: ./handsfree_setup.sh "/path/to/your/wow/client"'
    exit 1
fi

if [ ! -d "$1" ]; then
    echo 'Target must be the "World of Warcraft" directory.'
    exit 1
fi

if [ "$1" = "/" ] || [ "$1" = "" ]; then
    echo 'Path cannot be root or be empty.'
    exit 1
fi

if [ ! -d "$1/Data" ] && [ ! -d "$1/data" ]; then
    echo 'Target must be the "World of Warcraft" directory.'
    exit 1
fi

if [ "$ORCH" = "docker" ]; then
    if ! $ORCH ps -q >/dev/null 2>&1; then
        read -p "Docker daemon is not running. Try anyway? [y/N] " -n 1 -r
        echo
        if ! expr "$REPLY" 1>/dev/null : '^[Yy]$'; then
            exit 1
        fi
    fi
fi

if [ ! -d data ]; then
    mkdir data
fi

sh build_image.sh
if ! sh update_dbs.sh; then
    echo 'updates_dbs step failed. exiting...'
    exit 1
fi
if ! sh extract.sh "$1"; then
    echo 'extract step failed. exiting...'
    exit 1
fi

echo 'Setup finished! Edit "etc/playerbot.conf" to optionally disable playerbots.'
echo 'To create your account use "podman compose up -d" or "docker compose up -d" to start the composition, then run "enter_console.sh" to log into the terminal.'
