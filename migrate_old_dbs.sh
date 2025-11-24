#!/bin/sh

. ./preamble.sh

if [ ! "$(checksqlite)" ]; then
    echo 'sqlite3 not found. Cannot run DB migration natively. Use "./sqlite_shell.sh" to run from within the container.'
fi

echo "Backing up realmd Database"
truncate -s 0 realmd_backup.sql
echo "BEGIN TRANSACTION;" > realmd_backup.sql
for t in $(sqlite3 -batch databases/wotlkrealmd.sqlite ".mode list" "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'realmd_db_version';"); do
    echo "-- $t"
    sqlite3 -batch databases/wotlkrealmd.sqlite ".mode insert $t" ".headers on" "SELECT * FROM \"$t\";"
done >> realmd_backup.sql
echo "COMMIT TRANSACTION;" >> realmd_backup.sql

echo "Backing up characters Database"
truncate -s 0 characters_backup.sql
echo "BEGIN TRANSACTION;" > characters_backup.sql
for t in $(sqlite3 -batch databases/wotlkcharacters.sqlite ".mode list" "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'character_db_version';"); do
    echo "-- $t"
    sqlite3 -batch databases/wotlkcharacters.sqlite ".mode insert $t" ".headers on" "SELECT * FROM \"$t\";"
done >> characters_backup.sql
echo "COMMIT TRANSACTION;" >> characters_backup.sql

rm -rf databases
sh update_dbs.sh
sh db_restore.sh
