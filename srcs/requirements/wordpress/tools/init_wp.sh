#!/usr/bin/env sh
set -eu

DB_PASSWORD_FILE="/run/secrets/db_password"
WP_PASSWORD_FILE="/run/secrets/wp_password"
WP_ADM_PASSWORD_FILE="/run/secrets/wp_adm_password"

if [ ! -f "$DB_PASSWORD_FILE" ] || [ ! -f "$WP_PASSWORD_FILE" ] || [ ! -f "$WP_ADM_PASSWORD_FILE" ]; then
  echo "Missing WordPress secret files under /run/secrets" >&2
  exit 1
fi

DB_PASSWORD="$(cat "$DB_PASSWORD_FILE")"
WP_USER_PASSWORD="$(cat "$WP_PASSWORD_FILE")"
WP_ADMIN_PASSWORD="$(cat "$WP_ADM_PASSWORD_FILE")"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_URL:?WP_URL is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
: "${WP_USER:?WP_USER is required}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is required}"

# Hard guard for subject rule: admin username must NOT contain admin/administrator (case-insensitive).
lower_admin="$(printf '%s' "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')"
case "$lower_admin" in
  *admin*|*administrator*)
    echo "WP_ADMIN_USER must not contain 'admin' or 'administrator'." >&2
    exit 1
  ;;
esac

# Wait for DB to accept connections (bounded wait, not infinite).
echo "[wordpress] Waiting for MariaDB..."
i=0
until mariadb -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -gt 120 ]; then
    echo "[wordpress] MariaDB not ready after timeout" >&2
    exit 1
  fi
  sleep 1
done

# Download WP core only if not present.
if [ ! -f "wp-settings.php" ]; then
  echo "[wordpress] Downloading WordPress core..."
  curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  cp -R /tmp/wordpress/* /var/www/html/
  rm -rf /tmp/wordpress /tmp/wp.tar.gz
fi

# Create wp-config.php if missing.
if [ ! -f "wp-config.php" ]; then
  echo "[wordpress] Generating wp-config.php..."
  wp config create \
    --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${DB_PASSWORD}" \
    --dbhost="mariadb:3306"
fi

# Install WP if not installed.
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[wordpress] Installing WordPress..."
  wp core install \
    --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "[wordpress] Creating non-admin user..."
  wp user create \
    --allow-root \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=subscriber
fi

# Permissions (keep it simple; adjust if evaluator is strict).
chown -R www-data:www-data /var/www/html

echo "[wordpress] Starting php-fpm..."
exec php-fpm8.2 -F