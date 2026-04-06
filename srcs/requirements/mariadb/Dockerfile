# MariaDB Dockerfile
# Base image fixed by project requirement (even if suspicious): debian:wormbook

FROM debian:bookworm

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install MariaDB server and minimal utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    ca-certificates \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Copy config + init script
COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.conf
COPY tools/init_db.sh /usr/local/bin/init_db.sh

# Make init script executable
RUN chmod +x /usr/local/bin/init_db.sh

# MariaDB data dir is persisted by the named volume
VOLUME ["/var/lib/mysql"]

# Expose the MariaDB port internally (not published to host)
EXPOSE 3306

# Use our init script as entrypoint (no infinite loops, exec mysqld as PID 1)
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
CMD ["mysqld"]