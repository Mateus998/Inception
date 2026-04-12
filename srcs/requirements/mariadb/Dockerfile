FROM debian:bookworm

# Install MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB configuration
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy and set up the initialization script
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Expose MariaDB default port
EXPOSE 3306

# Run the init script as entrypoint
ENTRYPOINT ["init_db.sh"]