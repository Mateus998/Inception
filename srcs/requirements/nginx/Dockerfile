FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/inception
COPY tools/init_nginx.sh /usr/local/bin/init_nginx.sh
RUN chmod +x /usr/local/bin/init_nginx.sh

RUN ln -sf /etc/nginx/sites-available/inception /etc/nginx/sites-enabled/inception \
    && rm -f /etc/nginx/sites-enabled/default \
    && mkdir -p /etc/nginx/ssl

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/init_nginx.sh"]
