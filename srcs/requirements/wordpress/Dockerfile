FROM alpine:3.22.3

# PHP-FPM + extensions needed for WP, plus mariadb-client for connectivity checks,
# curl/tar for downloading WordPress, and wp-cli for automated setup.
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-xml \
    php82-mbstring \
    php82-phar \
    php82-openssl \
    mariadb-client \
    curl \
    tar

# PHP-FPM pool configuration (listen on 9000 for NGINX fastcgi).
COPY conf/wordpress.cnf /etc/php82/php-fpm.d/wordpress.cnf

# Install wp-cli (phar)
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/init_wp.sh"]