# Build stage
FROM postgres:16 AS builder
ARG PGBACKREST_VERSION=2.52.1

# Install build dependencies and build pgBackRest
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl make gcc libpq-dev libssh2-1-dev libssl-dev libxml2-dev pkg-config \
    liblz4-dev libzstd-dev libbz2-dev libz-dev libyaml-dev ca-certificates \
    && update-ca-certificates \
    && mkdir -p /tmp/pgbackrest-release \
    && cd /tmp/pgbackrest-release \
    && curl -v -L -o pgbackrest.tar.gz https://github.com/pgbackrest/pgbackrest/archive/release/${PGBACKREST_VERSION}.tar.gz \
    && tar xvzf pgbackrest.tar.gz --strip-components=1 \
    && cd src \
    && ./configure \
    && make \
    && mv pgbackrest /usr/bin \
    && chmod 755 /usr/bin/pgbackrest \
    && pgbackrest version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Final stage
FROM postgres:16
# Copy pgBackRest from builder
COPY --from=builder /usr/bin/pgbackrest /usr/bin/pgbackrest

# Install other stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates openssh-server vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
CMD ["postgres", "-c", "max_connections=500"]
