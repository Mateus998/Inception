# USER_DOC — Inception (User Guide)

## 1) What this project provides
This stack runs a small web infrastructure using Docker Compose:

- **NGINX (HTTPS / TLS)**  
  Public entrypoint of the stack. It terminates TLS and forwards PHP requests to PHP-FPM.
- **WordPress (PHP-FPM)**  
  The website + WordPress administration panel.
- **MariaDB**  
  Database used by WordPress.

Only **NGINX** is exposed to the host, and only on **port 443**.

---

## 2) Start / stop the project

### Start (build + run)
From the repository root:

```bash
make
```

This will:
- create the required data directories under `/home/<login>/data/`
- build the Docker images
- start the containers

### Stop and remove containers
```bash
make down
```

### Stop without removing containers
```bash
make stop
```

### Start again (after stop)
```bash
make start
```

### Restart everything
```bash
make restart
```

### Full reset (WARNING: deletes persistent data)
```bash
make re
```

---

## 3) Access the website and admin panel

### Domain
The required domain is:

- `https://mateferr.42.fr`

You must ensure it resolves to your VM IP address.

### URLs
- Website: `https://mateferr.42.fr`
- Admin panel: `https://mateferr.42.fr/wp-admin`

Note: The TLS certificate is self-signed, so your browser will warn you.

---

## 4) Credentials (where to find and manage them)

### Non-secret configuration
Non-sensitive variables are stored in:

- `srcs/.env`

This includes:
- `DOMAIN_NAME`
- database name/user
- WordPress usernames/emails (not passwords)

### Secrets (passwords)
Passwords are stored as Docker secrets in the repo root:

- `secrets/db_password`
- `secrets/db_root_password`
- `secrets/wp_adm_password`
- `secrets/wp_password`

These files should:
- exist before starting the project
- not be committed to a public repository

---

## 5) Check services status and logs

### Check containers are running
```bash
make ps
```

### Follow logs (all services)
```bash
make logs
```

### Logs per service
```bash
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f nginx
```

### Verify only HTTPS is exposed
```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

Expected: only the `nginx` container shows `0.0.0.0:443->443/tcp` (or similar).