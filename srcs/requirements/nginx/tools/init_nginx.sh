#!/usr/bin/env sh
set -eu

: "${DOMAIN_NAME:?DOMAIN_NAME is required}"

mkdir -p /etc/nginx/ssl

# Create a self-signed certificate if it does not exist yet.
# This keeps the container stateless: on new containers we re-generate,
# but you can also persist it if you want (not required by subject).
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
  echo "[nginx] Generating self-signed TLS certificate..."
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -days 365 \
    -subj "/C=PT/ST=Lisbon/L=Lisbon/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

# Validate config before starting (helps debugging).
nginx -t

echo "[nginx] Starting nginx..."
exec nginx -g "daemon off;"