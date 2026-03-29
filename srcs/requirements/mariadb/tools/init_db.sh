#!/usr/bin/env sh
set -eu

# Read secrets (Docker secrets are mounted as files under /run/secrets).
DB_ROOT_PASSWORD_FILE="/run/secrets/db_root_password"
DB_PASSWORD_FILE="/run/secrets/db_password"

if [ ! -f "$DB_ROOT_PASSWORD_FILE" ] || [ ! -f "$DB_PASSWORD_FILE" ]; then
  echo "Missing DB secret files under /run/secrets" >&2
  exit 1
fi

DB_ROOT_PASSWORD="$(cat "$DB_ROOT_PASSWORD_FILE")"
DB_PASSWORD="$(cat "$DB_PASSWORD_FILE")"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

# Initialize the data directory only if it's empty.
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[mariadb] Initializing data directory..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

  echo "[mariadb] Starting temporary server for bootstrap..."
  # Run server in the background without networking for secure bootstrap.
  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  # Wait for the socket to appear.
  i=0
  while [ ! -S /run/mysqld/mysqld.sock ]; do
    i=$((i+1))
    if [ "$i" -gt 50 ]; then
      echo "[mariadb] Bootstrap server did not start in time" >&2
      exit 1
    fi
    sleep 0.2
  done

  echo "[mariadb] Creating database and users..."
  mariadb --protocol=socket -uroot <<-SQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;

    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
SQL

  echo "[mariadb] Shutting down bootstrap server..."
  mariadb-admin --protocol=socket -uroot -p"${DB_ROOT_PASSWORD}" shutdown || true
  wait "$pid" || true
fi

# Ensure runtime directory exists.
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

echo "[mariadb] Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql