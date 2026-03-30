FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
  && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.cnf /etc/nginx/conf.d/default.conf
COPY tools/init_nginx.sh /usr/local/bin/init_nginx.sh
RUN chmod +x /usr/local/bin/init_nginx.sh

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/init_nginx.sh"]