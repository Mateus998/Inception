FROM debian:bookworm

# Install NGINX and OpenSSL (to generate the self-signed TLS certificate)
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Generate a self-signed TLS certificate valid for 365 days
# -x509       : output a self-signed certificate instead of a CSR
# -nodes      : no passphrase on the private key (required for automated startup)
# -days 365   : certificate validity
# -newkey rsa:2048 : generate a new 2048-bit RSA key pair
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out    /etc/ssl/certs/nginx.crt \
    -subj   "/C=PT/ST=Lisbon/L=Lisbon/O=42Lisboa/CN=mateferr.42.fr"

# Copy the NGINX configuration
COPY conf/nginx.cnf /etc/nginx/sites-available/default

# Copy and set up the init script
COPY tools/init_nginx.sh /usr/local/bin/init_nginx.sh
RUN chmod +x /usr/local/bin/init_nginx.sh

# Only port 443 (HTTPS) is exposed — as required by the subject
EXPOSE 443

ENTRYPOINT ["init_nginx.sh"]