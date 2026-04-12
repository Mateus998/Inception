#!/bin/bash
set -e

# ── Read secrets ────────────────────────────────────────────────────────────────
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADM_PASSWORD=$(cat /run/secrets/wp_adm_password)
WP_PASSWORD=$(cat /run/secrets/wp_password)

# ── Wait for MariaDB to be ready ────────────────────────────────────────────────
echo "Waiting for MariaDB..."
while ! (echo > /dev/tcp/mariadb/3306) 2>/dev/null; do
    sleep 2
done
echo "MariaDB is ready."

# ── Download WordPress core files (if not yet downloaded) ───────────────────────
if [ ! -f /var/www/html/wp-login.php ]; then
    wp core download \
        --locale=en_US \
        --allow-root
fi

# ── Create wp-config.php (if not yet created) ───────────────────────────────────
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root
fi

# ── Install WordPress (if not yet installed) ────────────────────────────────────
# "wp core is-installed" checks if the DB tables exist — true first-run indicator
if ! wp core is-installed --allow-root 2>/dev/null; then

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADM_USER}" \
        --admin_password="${WP_ADM_PASSWORD}" \
        --admin_email="${WP_ADM_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" "${WP_EMAIL}" \
        --user_pass="${WP_PASSWORD}" \
        --role=author \
        --allow-root

    echo "WordPress installed successfully."
fi

# ── Start php-fpm in the foreground ─────────────────────────────────────────────
exec php-fpm8.2 -F -R