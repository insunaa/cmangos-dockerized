# Dockerized CMaNGOS

> [!NOTE]
> By default `podman` is used. If `podman` is not present on your system, `docker` will be used.
> If you want to override which container orchestrator to use set the environment variable `CONTAINER_ORCHESTRATOR` to `podman` or `docker` or any other that is command-compatible.

### Getting started

> [!IMPORTANT]
> Dependencies: `bash`, `unzip`, `wget`, `sqlite3` and (`podman` + `podman-compose`) or (`docker` + `docker compose`)
> Please ensure these are installed on your systems, or some or all of the scripts will not function correctly.

> [!IMPORTANT]
> The very first thing to do is to rename or copy the `.env.dist` file to `.env` and edit it to choose the CMaNGOS expansion you wish this server to be for.

Next you should run `./build_image.sh` which will build with or without Playerbots depending on your settings in `.env`.
This will build the server components and extractors. It also allows you to update the CMaNGOS core to the latest version.

Next run `./update_dbs.sh` to download and install the SQLite Databases

Finally run `./extract.sh /path/to/your/World of Warcraft` to extract the data required to run the server.

To make changes to the configuration use the `.env` file.

Once all of this has finished you can start the server with `podman-compose up -d` and check the status with `podman-compose logs`

To create a user run `./enter_console.sh` to connect to the `mangosd` process. Log in with `ADMINISTRATOR` as user and `ADMINISTRATOR` as password.

> [!NOTE]
> There are 4 default users in the Database: `ADMINISTRATOR`, `GAMEMASTER`, `MODERATOR` and `PLAYER`, each of which have their account name as their password.
> All 4 of these accounts are disabled for logging in from the client, but can be used to log in with the `./enter_console.sh` command.

The command to run is: `account create username password 3` replace `username` with your username and `password` with your password.
The `3` means that the account is enabled for the WotLK expansion and so does include classic and tbc.

To make your account into a GM account, use `account set gmlevel 3 username`.

### Updating

To update the core simply run `./build_image.sh` again.
To update the database simply run `./update_dbs.sh` again

After updating the core, the composition needs to be fully torn down with `podman-compose down` or `docker compose down` and not simply stopped for it to load the newly built core image.

### Special files

To override settings from the `compose.yml` you can create a `compose.override.yml` and use it to add or override values from the `compose.yml`.
Check the documentation of `docker` or `podman` for more information.

To change the configurations of your server, modify the `.env` (not the `.env.dist`) file. Check the top of [the reference CMaNGOS config file](https://raw.githubusercontent.com/cmangos/mangos-wotlk/refs/heads/master/src/mangosd/mangosd.conf.dist.in) for more information.

To change the name of your server or the IP of your server, copy the `realm.sql.dist` file to `realm.sql` and edit it to fit your needs.
It is automatically applied when you run `update_dbs.sh`.

## Experimental
If an update of the realmd and/or characters database is required there is an ***EXPERIMENTAL*** feature that allows backing up these databases and restoring them.

To do this you *first* run `./db_backup.sh` which will create 2 files: `realmd_backup.sql` and `characters_backup.sql`. Open them with a text editor to confirm that they are not empty.
If they are not empty in the next step *rename* your `databases` directory to `databases_old`, then run `update_dbs.sh` again. When this is done run `db_restore.sh`.

> [!WARNING]
> `db_restore.sh` works by first emptying the entire database and then adding the data from the 2 backup files. If these backups are not up-to-date or contain invalid SQL, this will make the `realmd` and `characters` dbs unusable. So be *absolutely sure* that you have renamed the folder with the original databases to avoid data loss.

> [!CAUTION]
> Carelessness in this process can and will delete all of your account data in these containers.

> [!TIP]
> There are also the `handsfree_setup.sh` and the `handsfree_update.sh` scripts, which *should* do the full setup without user intervention and do a full update with only a minor intervention.
> Especially the hands free update is dangerous, so only do it if you're sure.
