#!/usr/bin/env bash
set -euo pipefail

: "${DOMAIN_NAME:?}"

# substituir placeholder no conf
sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

exec "$@"