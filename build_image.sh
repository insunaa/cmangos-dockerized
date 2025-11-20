#!/bin/bash
source preamble.sh

$ORCH build --build-arg AHBOT=$BUILD_PLAYERBOTS --build-arg PLAYERBOTS=$BUILD_PLAYERBOTS --build-arg CMANGOS_EXPANSION=$CMANGOS_EXPANSION -t cmangos-$CMANGOS_EXPANSION:latest -t cmangos-$CMANGOS_EXPANSION:$(date -I) .

$ORCH rmi $($ORCH images --filter label=deleteme=true -q)
