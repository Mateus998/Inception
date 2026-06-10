#!/bin/bash
set -e

# generate the ssl certificates if not exist
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out  /etc/nginx/ssl/inception.crt \
        -subj "/C=PT/ST=Lisboa/O=42/CN=${DOMAIN_NAME}"
fi

# nginx is main process of container in foreground
exec nginx -g "daemon off;"
