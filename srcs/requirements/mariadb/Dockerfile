FROM debian:bookworm

# Install MariaDB server and some basic tooling.
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/lib/mysql/*

# Custom server config (bind, port, etc.)
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf

# Init script (creates DB + users on first run)
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/init_db.sh"]