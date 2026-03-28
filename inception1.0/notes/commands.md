# Repository stucture
```bash
mkdir -p srcs/requirements/{mariadb,wordpress,nginx,tools}
mkdir -p srcs/requirements/mariadb/{conf,tools}
mkdir -p srcs/requirements/wordpress/{conf,tools}
mkdir -p srcs/requirements/nginx/{conf,tools}

touch srcs/docker-compose.yml
touch srcs/.env
```

# Remaining folders
```bash
mkdir -p ~/data/{mariadb,wordpress}
```

# Self-signed certificate
```bash
mkdir -p srcs/requirements/nginx/certs

openssl req -x509 -nodes -newkey rsa:4096 -days 365 \
-keyout srcs/requirements/nginx/certs/localhost.key \
-out srcs/requirements/nginx/certs/localhost.crt \
-subj "/C=BR/ST=SP/L=SaoPaulo/O=42/OU=Inception/CN=localhost"
```

# create mariadb files
```bash
touch srcs/requirements/mariadb/Dockerfile
touch srcs/requirements/mariadb/tools/entrypoint.sh
touch srcs/requirements/mariadb/conf/my.cnf

chmod +x srcs/requirements/mariadb/tools/entrypoint.sh
```

## run mariadb
```bash
cd srcs

docker compose down --remove-orphans 2>/dev/null || true
docker compose build mariadb
docker compose up -d mariadb
```
## use config mariadb
```bash
docker inspect --format '{{json .State.Health}}' mariadb | sed 's/\\n/\n/g' || true
docker exec -it mariadb mariadb-admin ping -uroot -p"${MARIADB_ROOT_PASSWORD}" -h 127.0.0.1 --silent
docker exec -it mariadb mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "SHOW DATABASES;"
docker exec -it mariadb mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "SELECT User,Host FROM mysql.user;"
```

# create worpress files
```bash
touch requirements/wordpress/Dockerfile
touch requirements/wordpress/tools/entrypoint.sh
touch requirements/wordpress/conf/www.conf

chmod +x requirements/wordpress/tools/entrypoint.sh
```

## run wordpress
```bash
docker compose build wordpress
docker compose up -d mariadb wordpress
```

# create nginx files
```bash
cd srcs
mkdir -p requirements/nginx/conf requirements/nginx/tools
touch requirements/nginx/Dockerfile
touch requirements/nginx/conf/nginx.conf
touch requirements/nginx/conf/default.conf
touch requirements/nginx/tools/entrypoint.sh
chmod +x requirements/nginx/tools/entrypoint.sh
```

## run & verificate nginx
```bash
docker compose build nginx
docker compose up -d nginx
docker compose ps
docker logs nginx --tail=100
```

# access cmd
```bash
curl -kI https://localhost/
```