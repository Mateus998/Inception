#!/bin/bash
set -e

WP_DIR="/var/www/wordpress"
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB at ${MYSQL_HOST}:3306..."
until nc -z "${MYSQL_HOST}" 3306; do
    sleep 1
done
echo "MariaDB is ready."

# wordpress configuration if is first time
if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    # get WordPress file with wp-cli
    wp core download \
        --path="${WP_DIR}" \
        --locale=en_US \
        --allow-root

    # configuration file creation
    wp config create \
        --path="${WP_DIR}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${MYSQL_HOST}" \
        --allow-root

    # WordPress instalation and configuration
    wp core install \
        --path="${WP_DIR}" \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # extra user creation (not admin)
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --path="${WP_DIR}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root

    # allow php-fpm to write on wordpress files
    chown -R www-data:www-data "${WP_DIR}"
fi

# PHP-FPM is main process of container
exec php-fpm8.2 --nodaemonize
