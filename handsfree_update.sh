#!/bin/sh
# shellcheck disable=SC3045
if [ -z "$INSIDE_CONTAINER" ]; then
    echo 'Updating the core.'
    sleep 3s
    sh build_image.sh
fi

read -p "Also update the Databases? [y/N] " -r
echo
if ! expr "$REPLY" 1>/dev/null : '^[Yy]$'; then
    exit 1
fi

if [ ! -d databases ]; then
    echo 'No databases to update found'
    exit 1
fi

if [ -d databases_old ]; then
    echo '"databases_old" directory found. Please rename or delete it.'
    exit 1
fi

echo 'Updating all Databases. If errors occur, delete the "databases" directory and rename "databases_old" to "databases"'
sleep 3s
sh db_backup.sh
mv databases databases_old
sh update_dbs.sh
sh db_restore.sh
