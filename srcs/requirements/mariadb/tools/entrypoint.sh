#!/usr/bin/env bash
set -euo pipefail                                # Safer bash: exit on error (-e), error on unset vars (-u), fail pipelines if any cmd fails

if [ "$(id -u)" -eq 0 ]; then                    # If the script is running as root (UID 0)...
  mkdir -p /run/mysqld /var/lib/mysql            # Create runtime dir for the socket/PID and the MariaDB data directory (if missing)
  chown -R mysql:mysql /run/mysqld /var/lib/mysql # Ensure the mysql user owns these dirs (MariaDB often refuses to run with wrong perms)
fi                                               # End of the root-only permissions fix

: "${MARIADB_DATABASE:?}"                        # Require MARIADB_DATABASE to be set; otherwise exit with an error
: "${MARIADB_USER:?}"                            # Require MARIADB_USER to be set; otherwise exit with an error
: "${MARIADB_PASSWORD:?}"                        # Require MARIADB_PASSWORD to be set; otherwise exit with an error
: "${MARIADB_ROOT_PASSWORD:?}"                   # Require MARIADB_ROOT_PASSWORD to be set; otherwise exit with an error

if [ ! -d "/var/lib/mysql/mysql" ]; then         # If the system database directory doesn't exist, this is a first-time initialization
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null  # Create initial MariaDB system tables in datadir (silent output)

  cat > /tmp/init.sql << SQL                     # Write an SQL initialization script to /tmp/init.sql (here-doc)
    FLUSH PRIVILEGES;                            
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;
SQL
: '
heredoc lines explanation
Reload privilege tables (safe to do before/after user changes)
Set root password for local root account
Create WP DB with utf8mb4 defaults
Create a user allowed to connect from any host (%)
Give that user full rights on that database
Apply privilege changes immediately
'

  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock & # Start MariaDB temporarily: no TCP, only socket
  pid="$!"                                       # Store the background mysqld process PID so we can wait/shutdown cleanly later

  for i in $(seq 1 60); do                       # Loop up to 60 times (timeout ~60 seconds) waiting for mysqld to be ready
    if mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then # Ping server via Unix socket
      break                                      # If ping succeeds, server is ready; exit the loop
    fi                                           # End readiness check
    sleep 1                                      # Wait 1 second before trying again
  done                                           # End loop

  mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot < /tmp/init.sql # Run the init SQL as root via socket auth (no password yet)
  rm -f /tmp/init.sql                            # Delete the SQL file after applying it (avoid leaving secrets on disk)

  mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"${MARIADB_ROOT_PASSWORD}" shutdown # Stop the temp server cleanly
  wait "${pid}" || true                          # Wait for background mysqld to exit; ignore non-zero exit to avoid crashing the script
fi                                               # End first-time init block

exec mysqld --user=mysql --datadir=/var/lib/mysql # Replace the script with the real MariaDB server process (container main process)