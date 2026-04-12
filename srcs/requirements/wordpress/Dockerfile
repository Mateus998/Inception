FROM debian:bookworm

# Install php-fpm and all extensions required by WordPress
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI (command line tool to manage WordPress)
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Copy the php-fpm pool configuration
COPY conf/wordpress.cnf /etc/php/8.2/fpm/pool.d/www.conf

# Copy and set up the initialization script
COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

# WordPress files will live here (matches the named volume)
WORKDIR /var/www/html

# Expose the php-fpm port (NGINX will connect to WordPress through this)
EXPOSE 9000

ENTRYPOINT ["init_wp.sh"]