FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    php-fpm php-mysql php-curl php-gd php-xml php-mbstring php-zip php-intl \
    mariadb-client \
    unzip \
    gosu \
  && rm -rf /var/lib/apt/lists/*

# php-fpm runtime dirs
RUN mkdir -p /run/php /var/www/html \
  && chown -R www-data:www-data /run/php /var/www/html

# wp-cli
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]