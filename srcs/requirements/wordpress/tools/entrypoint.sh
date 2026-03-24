#!/usr/bin/env bash
set -euo pipefail

: "${DOMAIN_NAME:?}"
: "${MARIADB_DATABASE:?}"
: "${MARIADB_USER:?}"
: "${MARIADB_PASSWORD:?}"

: "${WP_TITLE:?}"
: "${WP_ADMIN_USER:?}"
: "${WP_ADMIN_PASSWORD:?}"
: "${WP_ADMIN_EMAIL:?}"

: "${WP_USER:?}"
: "${WP_USER_PASSWORD:?}"
: "${WP_USER_EMAIL:?}"

DB_HOST="mariadb"
WP_PATH="/var/www/html"

as_www() {
  gosu www-data:www-data "$@"
}

wait_for_db() {
  for i in $(seq 1 60); do
    if mariadb-admin ping -h "${DB_HOST}" -u"${MARIADB_USER}" -p"${MARIADB_PASSWORD}" --silent >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

mkdir -p "${WP_PATH}"
chown -R www-data:www-data "${WP_PATH}"

wait_for_db

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
    as_www wp core download --path="${WP_PATH}" --locale=en_US
  fi

  as_www wp config create \
    --path="${WP_PATH}" \
    --dbname="${MARIADB_DATABASE}" \
    --dbuser="${MARIADB_USER}" \
    --dbpass="${MARIADB_PASSWORD}" \
    --dbhost="${DB_HOST}" \
    --skip-check

  as_www wp core install \
    --path="${WP_PATH}" \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email

  as_www wp user create \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=subscriber \
    --path="${WP_PATH}"
fi

exec "$@"
