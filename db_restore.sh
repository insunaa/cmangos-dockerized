#!/bin/sh
# shellcheck disable=SC3045
. ./preamble.sh

if [ ! "$(checksqlite)" ]; then
    echo 'sqlite3 not found. Cannot run DB Restore natively. Use "./sqlite_shell.sh" to run from within the container.'
fi

read -p "Are you sure? This will delete your current database if you do not have the most recent version backed up. [y/N] " -n 1 -r
echo
if ! expr "$REPLY" 1>/dev/null : '^[Yy]$'; then
    exit 1
fi

if [ ! -s realmd_backup.sql ]; then
    "No Realmd Backup detected. Aborting"
    exit 1
fi

echo "Deleting the realmd Database"
for t in $(sqlite3 -batch databases/realmd.sqlite ".mode list" "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'realmd_db_version';"); do
  sqlite3 -batch databases/realmd.sqlite "DELETE FROM \"$t\";"
done
echo "Restoring the realmd Database"
sqlite3 -batch databases/realmd.sqlite < realmd_backup.sql

if [ ! -s characters_backup.sql ]; then
    "No Characters Backup detected. Aborting"
    exit 1
fi

echo "Deleting the characters Database"
for t in $(sqlite3 -batch databases/characters.sqlite ".mode list" "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'character_db_version';"); do
  sqlite3 -batch databases/characters.sqlite "DELETE FROM \"$t\";"
done
echo "Restoring the characters Database"
sqlite3 -batch databases/characters.sqlite < characters_backup.sql
