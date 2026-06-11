*This project has been created as part of the 42 curriculum by mateferr*

# Inception

## Description

Inception is a system administration project that consists of setting up a small infrastructure using Docker and Docker Compose inside a virtual machine. The goal is to run a WordPress website backed by a MariaDB database, served through an NGINX reverse proxy with TLS encryption.

Each service runs in its own dedicated container, built from a custom Dockerfile based on Debian Bookworm. No pre-built images from Docker Hub are used (except the base OS image).

### Project Description

The infrastructure is composed of three containers communicating over a custom Docker network:

```
Browser (HTTPS :443)
    └── NGINX ──(FastCGI :9000)──► WordPress + PHP-FPM
                                        └──(MySQL :3306)──► MariaDB
```

**Design choices:**

- Images are built from `debian:bookworm` to have full control over installed packages and configuration.
- Passwords are never written in Dockerfiles or environment variables — they are stored as Docker secrets and mounted at `/run/secrets/` inside the containers.
- A custom Docker bridge network isolates the containers from the host and from each other, except through defined ports.
- Two named volumes persist data across container restarts: one for the WordPress files and one for the MariaDB database.

---

### Virtual Machines vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| **Isolation** | Full OS-level isolation | Process-level isolation |
| **Size** | GBs (full OS image) | MBs (only what's needed) |
| **Boot time** | Minutes | Seconds |
| **Use case** | Run different OSes | Run isolated services |

Docker containers share the host kernel, making them lighter and faster than VMs. For this project, Docker is ideal because each service (NGINX, WordPress, MariaDB) is independent and only needs its specific packages.

---

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| **Storage** | Files on disk, mounted at `/run/secrets/` | Passed directly to the process |
| **Visibility** | Not exposed in `docker inspect` | Visible in `docker inspect` |
| **Use case** | Passwords, tokens, credentials | Non-sensitive config (hostnames, usernames) |

In this project, all passwords (`MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`, `WP_ADMIN_PASSWORD`, `WP_USER_PASSWORD`) are stored as Docker secrets in the `secrets/` folder. Non-sensitive variables (domain name, usernames, database name) are stored in `srcs/.env`.

---

### Docker Network vs Host Network

| | Docker Network | Host Network |
|---|---|---|
| **Isolation** | Containers have their own network namespace | Containers share the host network stack |
| **Security** | Containers only expose what is explicitly published | All ports are accessible on the host |
| **DNS** | Containers resolve each other by name | No automatic service discovery |

This project uses a custom bridge network (`inception_net`). Containers communicate internally by name (e.g., WordPress connects to `mariadb:3306`). Only port `443` is published to the host.

---

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker | The user |
| **Location** | Docker-managed path | Any path on the host |
| **Portability** | High | Low (depends on host path) |
| **Use case** | Persistent service data | Development, local file access |

This project uses named volumes backed by specific host directories (`/home/mateferr/data/db` and `/home/mateferr/data/wordpress`), as required by the subject. Bind mounts are not used.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Add the domain to `/etc/hosts`:

```bash
echo "127.0.0.1 mateferr.42.fr" | sudo tee -a /etc/hosts
```

- Create the `secrets/` files with your passwords:

```
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

### Installation and Execution

```bash
# Build and start all containers
make

# Stop containers without removing them
make stop

# Start stopped containers
make start

# Restart all containers
make restart

# View logs in real time
make logs

# Show container status
make ps

# Stop and remove containers (keeps data)
make down

# Stop, remove containers, volumes and data
make clean

# Full cleanup including Docker images
make fclean

# Full rebuild from scratch
make re
```

### Access

| URL | Description |
|-----|-------------|
| `https://mateferr.42.fr` | WordPress site |
| `https://mateferr.42.fr/wp-login.php` | Login page (admin and users) |
| `https://mateferr.42.fr/wp-admin` | Admin dashboard |

> The browser will show a security warning because the TLS certificate is self-signed. Click "Advanced" and proceed to continue.

---

## Resources

### Documentation

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [Understanding Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### AI Usage

Claude, NotebookLM and GitHub Copilot were used as assistants during this project in the following areas:

- **Researching** — resuming and explaining all documentations and project examples for quicker understanding of the project tools.
- **Debugging** — identifying sintaxe and compiling errors during initial development.
- **Configuration review** — reviewing NGINX, PHP-FPM and MariaDB configuration files for correctness and Docker compatibility.
- **Content review** — reviewing and suggesting the theoric information present on the .md files.

All generated content was reviewed, tested and understood before being included in the project.
