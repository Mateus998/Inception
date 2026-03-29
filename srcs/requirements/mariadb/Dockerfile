FROM alpine:3.22.3

# Install MariaDB server and some basic tooling.
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    bash

# Custom server config (bind, port, etc.)
COPY conf/mariadb.cnf /etc/my.cnf.d/mariadb.cnf

# Init script (creates DB + users on first run)
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/init_db.sh"]