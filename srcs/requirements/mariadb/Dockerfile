# base image (OS) to run the container
FROM debian:bookworm

# container dependencies instalation for debian
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/*

# copy of the config file and script to the container
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh
# making the script executable
RUN chmod +x /usr/local/bin/init_db.sh

# information about the port used inside mariadb
EXPOSE 3306

# command executed after the container creation
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
