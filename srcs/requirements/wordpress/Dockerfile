# WordPress (php-fpm) Dockerfile
# Base image fixed by project requirement (even if suspicious): debian:wormbook

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install PHP-FPM + extensions, wp-cli dependencies, mariadb client (for waiting/db checks)
RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip php-redis \
    mariadb-client \
    curl \
    ca-certificates \
    bash \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI (official phar)
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Copy configs and init script
COPY conf/wordpress.conf /etc/php/8.2/fpm/pool.d/wordpress.conf
COPY tools/init_wp.sh /usr/local/bin/init_wp.sh

RUN chmod +x /usr/local/bin/init_wp.sh

# WordPress files live here (named volume in compose)
WORKDIR /var/www/html

EXPOSE 9000

# Init script will setup WP then exec php-fpm as PID 1
ENTRYPOINT ["/usr/local/bin/init_wp.sh"]
CMD ["php-fpm8.2", "-F"]