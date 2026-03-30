FROM debian:bookworm

# PHP-FPM + extensions needed for WP, plus mariadb-client for connectivity checks,
# curl/tar for downloading WordPress, and wp-cli for automated setup.
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl \
    tar \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Install wp-cli (phar)
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# PHP-FPM pool configuration (listen on 9000 for NGINX fastcgi).
COPY conf/wordpress.cnf /etc/php/8.2/fpm/pool.d/wordpress.cnf

COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/init_wp.sh"]