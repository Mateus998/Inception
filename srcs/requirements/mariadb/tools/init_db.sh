#!/bin/bash
set -e # stop executing if something fail

DATADIR="/var/lib/mysql"
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# create folder for temp files and define user for mariadb config
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# if is the first configuration of mariadb
if [ ! -d "${DATADIR}/mysql" ]; then

    # install base structure of mariadb
    mysql_install_db --user=mysql --datadir="${DATADIR}" --skip-test-db

    # start mariadb in background and get it's process id
    mysqld --user=mysql --skip-networking &
    pid=$!

    # script wait until mariadb is initiated
    until mysql -u root -h localhost -e "SELECT 1" &>/dev/null; do
        sleep 0.5
    done

    # database configuration - user creation
    mysql -u root -h localhost <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    # end background process
    kill "${pid}"
    wait "${pid}"
fi

# mariadb becomes the main process of the container PID 1
exec mysqld --user=mysql
