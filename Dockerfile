# Build stage
FROM public.ecr.aws/docker/library/postgres:18.0 AS builder
ARG PGBACKREST_VERSION=2.57.0

# Install build dependencies and build pgBackRest
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl meson ninja-build gcc libpq-dev libssh2-1-dev libssl-dev libxml2-dev pkg-config \
    liblz4-dev libzstd-dev libbz2-dev libz-dev libyaml-dev ca-certificates > /dev/null 2>&1 \
    && update-ca-certificates > /dev/null 2>&1 \
    && mkdir -p /tmp/pgbackrest-release \
    && cd /tmp/pgbackrest-release \
    && curl -s -L -o pgbackrest.tar.gz https://github.com/pgbackrest/pgbackrest/archive/release/${PGBACKREST_VERSION}.tar.gz \
    && tar xzf pgbackrest.tar.gz --strip-components=1 \
    && meson setup --prefix /usr build \
    && ninja -C build install \
    && pgbackrest version \
    && apt-get clean -qq \
    && rm -rf /var/lib/apt/lists/* /tmp/pgbackrest-release

# Final stage
FROM public.ecr.aws/docker/library/postgres:18.0
LABEL org.opencontainers.image.source="https://github.com/nuqayah/postgres-pgbackup"
# Copy pgBackRest from builder
COPY --from=builder /usr/bin/pgbackrest /usr/bin/pgbackrest

# Install other stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates openssh-server vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["postgres", "-c", "max_connections=500"]
