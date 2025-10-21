# PostgreSQL Nuqayah Custom Image

![GitHub CI](https://github.com/nuqayah/postgres-pgbackup/actions/workflows/publish.yml/badge.svg)
[![ghcr.io badge](https://ghcr-badge.egpl.dev/nuqayah/postgres-pgbackup/latest_tag?trim=major&label=GitHub%20Registry&color=steelblue)](https://github.com/nuqayah/postgres-pgbackup/pkgs/container/postgres-pgbackup)
[![ghcr.io size badge](https://ghcr-badge.egpl.dev/nuqayah/postgres-pgbackup/size?tag=latest&label=Image%20size&color=steelblue)](https://github.com/nuqayah/postgres-pgbackup/pkgs/container/postgres-pgbackup)

This `Dockerfile` builds a custom image which adds the below features to `postgres:18`:

- pgBackrest (Uses SFTP for backup)
- vim
- openssh
- Ability to run container in disaster recovery mode by setting environment variable POSTGRES_DISASTER_RECOVERY=1, in this mode the container starts but postgres does not (In order to do a pgBackrest restore for example).

## Building

If you need to build with a different pgBackRest version, you can do so by passing the --build-arg flag to the docker build command:

`docker build --build-arg PGBACKREST_VERSION=2.57.0 -t postgres-nuqayah:18 .`


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
