# NGINX Dockerfile
# Base image fixed by project requirement (even if suspicious): debian:wormbook

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install nginx + openssl for self-signed cert generation
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    ca-certificates \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Remove default site to avoid confusion
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default || true

# Copy nginx config and init script
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/init_ng.sh /usr/local/bin/init_ng.sh

RUN chmod +x /usr/local/bin/init_ng.sh

EXPOSE 80 443

# Init script will generate certs (if missing) then exec nginx as PID 1
ENTRYPOINT ["/usr/local/bin/init_ng.sh"]
CMD ["nginx", "-g", "daemon off;"]