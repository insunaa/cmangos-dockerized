#!/bin/bash
source preamble.sh

if [ ! "$(checkwget)" ] || [ ! "$(checkunzip)" ]; then
    echo 'wget or unzip dependencies not found. Please make sure they are installed.'
    exit 1
fi

wget --quiet -O dbs.zip https://github.com/cmangos/$CMANGOS_EXPANSION-db/releases/download/latest/$CMANGOS_EXPANSION-sqlite-db.zip

if [ ! -f dbs.zip ]; then
    echo "Failed to download Databases"
    exit 1
fi

if [ ! -d databases ]; then
    mkdir databases
fi

if [ ! -f databases/mangos.sqlite ]; then
    unzip dbs.zip -d databases
    mv -f databases/"$CMANGOS_EXPANSION"mangos.sqlite databases/mangos.sqlite
    mv -f databases/"$CMANGOS_EXPANSION"realmd.sqlite databases/realmd.sqlite
    mv -f databases/"$CMANGOS_EXPANSION"characters.sqlite databases/characters.sqlite
    mv -f databases/"$CMANGOS_EXPANSION"logs.sqlite databases/logs.sqlite
    if [ "$(checksqlite)" ]; then
        if [ -f databases/realmd.sqlite ]; then
            sqlite3 -batch databases/realmd.sqlite "UPDATE account SET locked=1 WHERE id<5;" ".exit"
        fi
    else
        echo 'sqlite3 not found. Cannot lock default accounts.'
    fi
else
    unzip -o dbs.zip "$CMANGOS_EXPANSION"mangos.sqlite -d databases
    mv -f databases/"$CMANGOS_EXPANSION"mangos.sqlite databases/mangos.sqlite
fi

rm dbs.zip

if [ "$(checksqlite)" ]; then
    if [ -f custom.sql ]; then
        sqlite3 -batch databases/mangos.sqlite < custom.sql
    fi
else
    echo 'sqlite3 not found. Not applying custom DB changes.'
fi

if [ "$(checksqlite)" ]; then
    if [ -f realm.sql ]; then
        sqlite3 -batch databases/realmd.sqlite < realm.sql
    fi
else
    echo 'sqlite3 not found. Not applying realm.sql changes to DB.'
fi
