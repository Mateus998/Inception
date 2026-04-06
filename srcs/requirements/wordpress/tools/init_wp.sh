#!/bin/bash
# init_wp.sh
# 1) Wait for MariaDB to be reachable
# 2) Download WordPress (if missing) into /var/www/html (volume)
# 3) Create wp-config.php (if missing)
# 4) Install WordPress (if not installed)
# 5) Create an additional user
# Then exec php-fpm in foreground as PID 1 (no infinite loops).

set -euo pipefail

read_secret() {
  local var_name="$1"      # e.g. MYSQL_PASSWORD_FILE
  local file_path="${!var_name:-}"

  if [[ -z "${file_path}" || ! -f "${file_path}" ]]; then
    echo "Error: Secret file env ${var_name} is not set or file not found." >&2
    exit 1
  fi
  tr -d '\n' < "${file_path}"
}

: "${WP_DOMAIN:?Missing WP_DOMAIN}"
: "${WP_TITLE:?Missing WP_TITLE}"
: "${WP_ADMIN_USER:?Missing WP_ADMIN_USER}"
: "${WP_ADMIN_EMAIL:?Missing WP_ADMIN_EMAIL}"
: "${WP_USER:?Missing WP_USER}"
: "${WP_USER_EMAIL:?Missing WP_USER_EMAIL}"

: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"
: "${MYSQL_HOST:?Missing MYSQL_HOST}"

MYSQL_PASSWORD="$(read_secret MYSQL_PASSWORD_FILE)"
WP_ADMIN_PASSWORD="$(read_secret WP_ADMIN_PASSWORD_FILE)"
WP_USER_PASSWORD="$(read_secret WP_USER_PASSWORD_FILE)"

# Ensure permissions are sane (volume may be owned by root on first mount)
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Wait for DB
echo "[wordpress] Waiting for MariaDB at ${MYSQL_HOST}..."
for i in {1..60}; do
  if mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" "${MYSQL_DATABASE}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Download WP if missing
if [[ ! -f "/var/www/html/wp-settings.php" ]]; then
  echo "[wordpress] Downloading WordPress core..."
  # Run wp-cli as www-data to avoid root-owned files in the volume
  sudo -u www-data wp core download --path=/var/www/html --allow-root=false >/dev/null
fi

# Create wp-config.php if missing
if [[ ! -f "/var/www/html/wp-config.php" ]]; then
  echo "[wordpress] Creating wp-config.php..."
  sudo -u www-data wp config create \
    --path=/var/www/html \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="${MYSQL_HOST}" \
    --skip-check \
    --allow-root=false >/dev/null
fi

# Install WP if not installed yet
if ! sudo -u www-data wp core is-installed --path=/var/www/html --allow-root=false >/dev/null 2>&1; then
  echo "[wordpress] Installing WordPress..."
  sudo -u www-data wp core install \
    --path=/var/www/html \
    --url="https://${WP_DOMAIN}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root=false >/dev/null
else
  echo "[wordpress] WordPress already installed, skipping core install."
fi

# Ensure the additional user exists
if ! sudo -u www-data wp user get "${WP_USER}" --path=/var/www/html --allow-root=false >/dev/null 2>&1; then
  echo "[wordpress] Creating extra user..."
  sudo -u www-data wp user create \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=subscriber \
    --path=/var/www/html \
    --allow-root=false >/dev/null
fi

echo "[wordpress] Starting php-fpm..."
exec "$@"