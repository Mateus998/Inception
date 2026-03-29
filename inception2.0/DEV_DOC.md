# DEV_DOC — Inception (Developer Guide)

## 1) Environment prerequisites
Target environment:
- A **Virtual Machine** (VM) running Linux (your VM OS can be Debian).
- Docker and Docker Compose installed.

### Quick verification
```bash
docker --version
docker compose version
```

---

## 2) Repository layout (important paths)
At a high level:

- `Makefile` (root): entry point for running the project
- `srcs/docker-compose.yml`: service definitions
- `srcs/.env`: non-sensitive configuration
- `secrets/`: password files used as Docker secrets
- `srcs/requirements/<service>/`: Dockerfile + configs + init scripts per service

Services:
- `srcs/requirements/mariadb/`
- `srcs/requirements/wordpress/`
- `srcs/requirements/nginx/`

```bash
mkdir -p secrets \
  srcs/requirements/mariadb/{conf,tools} \
  srcs/requirements/wordpress/{conf,tools} \
  srcs/requirements/nginx/{conf,tools}

touch Makefile \
  srcs/.env \
  srcs/docker-compose.yml \
  secrets/db_password \
  secrets/db_root_password \
  secrets/wp_adm_password \
  secrets/wp_password \
  srcs/requirements/mariadb/Dockerfile \
  srcs/requirements/wordpress/Dockerfile \
  srcs/requirements/nginx/Dockerfile

touch srcs/requirements/mariadb/conf/mariadb.cnf \
  srcs/requirements/mariadb/tools/init_db.sh \
  srcs/requirements/wordpress/conf/wordpress.cnf \
  srcs/requirements/wordpress/tools/init_wp.sh \
  srcs/requirements/nginx/conf/nginx.cnf \
  srcs/requirements/nginx/tools/init_nginx.sh

chmod +x srcs/requirements/mariadb/tools/init_db.sh
chmod +x srcs/requirements/wordpress/tools/init_wp.sh
chmod +x srcs/requirements/nginx/tools/init_nginx.sh
```

---

## 3) Configuration files

### 3.1 `.env` file
Edit:
- `srcs/.env`

Must contain:
- `LOGIN` (used for host data path)
- `DOMAIN_NAME` (must be `mateferr.42.fr`)
- DB name/user
- WordPress users/emails

Passwords must NOT be stored in Dockerfiles.

### 3.2 Secrets (required before running)
Create the secrets folder and files at repository root:

```bash
mkdir -p secrets
touch secrets/db_password
touch secrets/db_root_password
touch secrets/wp_adm_password
touch secrets/wp_password
# password creation example: 8246 as test password
printf '%s' '8246' > secrets/db_password
printf '%s' '8246' > secrets/db_root_password
printf '%s' '8246' > secrets/wp_password
printf '%s' '8246' > secrets/wp_adm_password
chmod 600 secrets/*
```

Each file must contain only the secret value (no quotes, no extra lines).

---

## 4) Build and launch (using Makefile)
From repository root:

### Build + start
```bash
make
```

### Stop/remove
```bash
make down
```

### Rebuild images
```bash
make build
```

### Logs / status
```bash
make logs
make ps
```

---

## 5) Data persistence (volumes and host paths)

The project stores persistent data on the host machine in:

- `/home/<login>/data/mariadb` (MariaDB data directory)
- `/home/<login>/data/wordpress` (WordPress files)

`<login>` is taken from `$(shell whoami)` at the beginnig of the Makefile.

The Makefile creates these directories automatically:
```bash
make create_dirs
```

### Reset persistent data (WARNING)
To delete all WordPress and database data (full reset):
```bash
make fclean
# or
make re
```

---

## 6) Useful Docker Compose commands (manual management)

All commands below must be run from repository root:

### Validate compose configuration
```bash
docker compose -f srcs/docker-compose.yml config
```

### Build only
```bash
docker compose -f srcs/docker-compose.yml build
```

### Start / stop without rebuilding
```bash
docker compose -f srcs/docker-compose.yml up -d
docker compose -f srcs/docker-compose.yml stop
docker compose -f srcs/docker-compose.yml start
```

### Inspect running containers
```bash
docker compose -f srcs/docker-compose.yml ps
```

### Follow logs per service
```bash
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f nginx
```

---

## 7) Where to debug common problems

### Domain not resolving
Ensure `mateferr.42.fr` points to the VM IP on the machine you use to access the website.

### TLS warning in browser
Expected: the project uses a self-signed certificate.

### WordPress cannot connect to DB
Check:
- MariaDB logs: `docker compose -f srcs/docker-compose.yml logs -f mariadb`
- WordPress logs: `docker compose -f srcs/docker-compose.yml logs -f wordpress`
- Secret files exist and are readable by Docker

### Containers restart repeatedly
Use:
```bash
make ps
make logs
```
Then inspect the first error message from the container logs.