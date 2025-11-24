#!/bin/bash
source preamble.sh

if [ "$#" -lt 1 ]; then
    echo 'Usage: ./extract.sh "/path/to/your/wow/client"'
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo 'Target must be the "World of Warcraft" directory.'
    exit 1
fi

if [ "$1" = "/" ] || [ "$1" = "" ]; then
    echo 'Path cannot be root or be empty.'
    exit 1
fi

if [[ ! -d "$1/Data" ]] && [[ ! -d "$1/data" ]]; then
    echo 'Target must be the "World of Warcraft" directory.'
    exit 1
fi

if [ ! -d data ]; then
    mkdir data
fi

$COMPOSE_COMMAND run --rm -w '/mangos/bin/tools/' -v "$1:/client" -v './data:/output' --entrypoint "/bin/bash" mangosd "-c" "/mangos/bin/tools/ExtractResources.sh a /client /output"
