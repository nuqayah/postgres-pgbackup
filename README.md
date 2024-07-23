# PostgreSQL Nuqayah Custom Image

This `Dockerfile` builds a custom image which adds the below features to `postgresql:16`:

- pgBackrest (Uses SFTP for backup)
- vim
- openssh
- Ability to run container in disaster recovery mode by setting environment variable POSTGRES_DISASTER_RECOVERY=1, in this mode the container starts but postgres does not (In order to do a pgBackrest restore for example).

## Building

If you need to build with a different pgBackrest version, you can do so by passing the --build-arg flag to the docker build command:

`docker build --build-arg PGBACKREST_VERSION=2.53.0 -t postgres-nuqayah:16 .`


## Usage

The below volumes must be mounted inside the container:

- `pgbackrest.conf`: pgBackRest configuration at `/etc/pgbackrest.conf`
- `SSH_PATH`: a directory that contains ssh public and private keys
- `DB_DATA_PATH`: PostgreSQL data directory e.g. `/var/lib/postgresql/data`

PostgresSQL configuration in `/var/lib/postgresql/data/postgresql.conf` must be updated with:

```
archive_command = 'pgbackrest --stanza=main archive-push %p'
archive_mode = on
```

After starting the container, run `KEY="${KEY:-ed25519}" && USERID=$(docker compose exec -T db id -u postgres) && mkdir -p .ssh && cp ~/.ssh/*$KEY* .ssh/ && sudo chown -R $USERID:$USERID .ssh && sudo chmod 700 .ssh && sudo chmod 600 .ssh/id_$KEY && sudo chmod 644 .ssh/id_$KEY.pub` to copy and configure ssh keys.

See `docker-compose.yaml` for example usage.
