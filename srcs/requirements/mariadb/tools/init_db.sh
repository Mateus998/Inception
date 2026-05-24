#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "${DATADIR}/mysql" ]; then
    mysql_install_db --user=mysql --datadir="${DATADIR}" --skip-test-db

    mysqld --user=mysql --skip-networking &
    pid=$!

    until mysql -u root -h localhost -e "SELECT 1" &>/dev/null; do
        sleep 0.5
    done

    mysql -u root -h localhost <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    kill "${pid}"
    wait "${pid}"
fi

exec mysqld --user=mysql
