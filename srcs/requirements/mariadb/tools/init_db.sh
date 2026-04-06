#!/bin/bash
# init_db.sh
# Initializes MariaDB on first run using Docker secrets, then starts mysqld.
# No infinite loops; we exec mysqld at the end so it becomes PID 1.

set -euo pipefail

# Helper: read secret from *_FILE environment variable
read_secret() {
  local var_name="$1"      # e.g. MYSQL_ROOT_PASSWORD_FILE
  local file_path="${!var_name:-}"

  if [[ -z "${file_path}" || ! -f "${file_path}" ]]; then
    echo "Error: Secret file env ${var_name} is not set or file not found." >&2
    exit 1
  fi
  cat "${file_path}"
}

MYSQL_ROOT_PASSWORD="$(read_secret MYSQL_ROOT_PASSWORD_FILE)"
MYSQL_PASSWORD="$(read_secret MYSQL_PASSWORD_FILE)"

: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"

# If database directory is empty/uninitialized, run mariadb-install-db and bootstrap users/db
if [[ ! -d "/var/lib/mysql/mysql" ]]; then
  echo "[mariadb] Initializing database directory..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

  echo "[mariadb] Bootstrapping users and database..."
  # Start mysqld temporarily without networking for secure initialization
  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  # Wait until server is ready
  for i in {1..60}; do
    if mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  # Secure and create database + user
  mariadb --socket=/run/mysqld/mysqld.sock <<-SQL
    -- Set root password and allow root login only from localhost
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;

    -- Create application database and user
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  # Stop temporary server
  mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "${pid}" || true

  echo "[mariadb] Bootstrap done."
else
  echo "[mariadb] Existing database detected, skipping bootstrap."
fi

# Ensure runtime directory exists
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Start MariaDB in foreground (as PID 1)
echo "[mariadb] Starting mysqld..."
exec "$@" --user=mysql --datadir=/var/lib/mysql