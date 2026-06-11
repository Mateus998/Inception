# Developer Documentation

## Set up the environment from scratch

### Prerequisites

- Docker Engine installed and running
- Docker Compose plugin (v2+)
- `make` available
- Access to `sudo` (required for `make clean` to remove container-owned files)

**Add the domain to `/etc/hosts`:**
```bash
echo "127.0.0.1 mateferr.42.fr" | sudo tee -a /etc/hosts
```

---

### Secrets setup

The `secrets/` folder is excluded from the repository (`.gitignore`). It must be created manually on every new clone before running the project.

**Create the secrets folder and password files:**
```bash
mkdir -p secrets

echo "your_db_password"        > secrets/db_password.txt
echo "your_db_root_password"   > secrets/db_root_password.txt
echo "your_wp_admin_password"  > secrets/wp_admin_password.txt
echo "your_wp_user_password"   > secrets/wp_user_password.txt
```

Replace each value with a strong password of your choice.

**Expected structure:**
```
secrets/
├── db_password.txt        → MYSQL_PASSWORD (WordPress DB user)
├── db_root_password.txt   → MYSQL_ROOT_PASSWORD (MariaDB root)
├── wp_admin_password.txt  → WordPress admin account password
└── wp_user_password.txt   → WordPress editor account password
```

Secrets are mounted read-only inside containers at `/run/secrets/<filename_without_extension>` and read by the entrypoint scripts with `$(cat /run/secrets/<name>)`.

---

## Build and launch the project

All commands must be run from the root of the project (`Inception/`).

### Full build and start

```bash
make
```

This will:
1. Create `/home/mateferr/data/db` and `/home/mateferr/data/wordpress` on the host
2. Build all Docker images from their respective Dockerfiles
3. Start all three containers in detached mode

### Build images only (without starting)

```bash
make build
```

### Full rebuild from scratch

```bash
make re
```

This runs `make fclean` (removes everything) followed by `make` (full rebuild).

> `make re` requires `sudo` because `make clean` removes files owned by container users.

---

## Manage containers and volumes

### Container lifecycle

| Command | Description |
|---------|-------------|
| `make start` | Start stopped containers (no rebuild) |
| `make stop` | Stop running containers (data preserved) |
| `make restart` | Restart all containers |
| `make down` | Stop and remove containers (volumes kept) |
| `make ps` | Show container status |
| `make logs` | Follow logs from all containers (Ctrl+C to exit) |

### Inspect a specific container

```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

### Check logs for a single service

```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

### Test MariaDB directly

```bash
docker exec mariadb mysql -u wpuser -p$(cat secrets/db_password.txt) wordpress -e "SHOW TABLES;"
```

### Use MariaDB database

```bash
docker exec -it db bash
mysql -u app_user -p -h localhost
# password...
```
```SQL
USE "database_name";
CREATE TABLE users (id INT, name VARCHAR(100));
INSERT INTO users VALUES (1, 'user_example');
SELECT * FROM users;
```

### Cleanup

| Command | What it removes |
|---------|----------------|
| `make down` | Containers only |
| `make clean` | Containers + volumes + `/home/mateferr/data` (requires `sudo`) |
| `make fclean` | Everything above + all Docker images |

---

## Data storage and persistence

Project data is stored on the host machine under `/home/mateferr/data/` and mounted into the containers as named Docker volumes.

| Host path | Volume name | Used by | Contents |
|-----------|-------------|---------|----------|
| `/home/mateferr/data/db` | `srcs_db_data` | `mariadb` | MariaDB database files |
| `/home/mateferr/data/wordpress` | `srcs_wp_data` | `wordpress`, `nginx` | WordPress PHP files, uploads, themes |

**How persistence works:**

- On first run, `mariadb` initialises the database and creates the WordPress user and database. On subsequent runs, the existing data directory is detected and the init step is skipped.
- On first run, `wordpress` downloads WordPress, generates `wp-config.php` and installs the site. On subsequent runs, the presence of `wp-config.php` in the volume prevents reinstallation.
- The `nginx` container mounts the same WordPress volume read-only to serve static files (CSS, JS, images) directly without going through PHP-FPM.

**Volume configuration in `docker-compose.yml`:**
```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mateferr/data/db

  wp_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mateferr/data/wordpress
```

> Files inside these directories are owned by the container users (`mysql` for MariaDB, `www-data` for WordPress). This is why `sudo` is needed to remove them during `make clean`.
