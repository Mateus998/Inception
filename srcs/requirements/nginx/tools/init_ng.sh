#!/bin/bash
# init_ng.sh
# Generates a self-signed TLS certificate if not present, then starts nginx.
# No infinite loops; exec nginx as PID 1.

set -euo pipefail

SSL_DIR="/etc/nginx/ssl"
CRT="${SSL_DIR}/inception.crt"
KEY="${SSL_DIR}/inception.key"

mkdir -p "${SSL_DIR}"

if [[ ! -f "${CRT}" || ! -f "${KEY}" ]]; then
  echo "[nginx] Generating self-signed certificate..."
  # Minimal subject; domain is hardcoded in nginx.conf for simplicity (mateferr.42.fr)
  # This is not a secret.
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "${KEY}" \
    -out "${CRT}" \
    -days 365 \
    -subj "/C=BR/ST=SP/L=SaoPaulo/O=42Inception/OU=Dev/CN=mateferr.42.fr" >/dev/null 2>&1
  chmod 600 "${KEY}"
fi

echo "[nginx] Starting nginx..."
exec "$@"