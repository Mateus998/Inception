#!/bin/bash
set -e

# ── Read secrets ────────────────────────────────────────────────────────────────
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# ── Always ensure the socket directory exists ───────────────────────────────────
# This is required on every start, not just the first time
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# ── First-time initialization ───────────────────────────────────────────────────
if [ ! -d "/var/lib/mysql/mysql" ]; then

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld --user=mysql --bootstrap --skip-networking << EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

fi

# ── Start MariaDB ───────────────────────────────────────────────────────────────
exec mysqld --user=mysql