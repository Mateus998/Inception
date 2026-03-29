FROM alpine:3.22.3

RUN apk add --no-cache nginx openssl

COPY conf/nginx.cnf /etc/nginx/nginx.cnf
COPY tools/init_nginx.sh /usr/local/bin/init_nginx.sh
RUN chmod +x /usr/local/bin/init_nginx.sh

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/init_nginx.sh"]