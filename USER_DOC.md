# User Documentation

## What services does this stack provide?

The Inception stack runs three services, each in its own container:

| Service | Description | Accessible from outside? |
|---------|-------------|--------------------------|
| **NGINX** | Web server / reverse proxy — the only entry point | Yes, port `443` (HTTPS) |
| **WordPress** | The website and its admin panel | Only through NGINX |
| **MariaDB** | Database that stores all WordPress content | No |

---

## Start and stop the project

All commands must be run from the root of the project directory (`inception2/`).

**Start the project** (builds images if needed):
```bash
make
```

**Stop the project** (containers are kept, data is preserved):
```bash
make stop
```

**Start stopped containers again** (no rebuild):
```bash
make start
```

**Restart all containers:**
```bash
make restart
```

**Stop and remove containers** (data is preserved, images are kept):
```bash
make down
```

---

## Access the website and the administration panel

> Before accessing the site, make sure `mateferr.42.fr` points to your machine.
> Check that `/etc/hosts` contains the line: `127.0.0.1 mateferr.42.fr`

| URL | Description |
|-----|-------------|
| `https://mateferr.42.fr` | Public WordPress site |
| `https://mateferr.42.fr/wp-login.php` | Login page (admin and regular users) |
| `https://mateferr.42.fr/wp-admin` | Admin dashboard (admin only) |

> The browser will show a certificate warning because the TLS certificate is self-signed. Click **Advanced** and then **Proceed** to continue.

---

## Locate and manage credentials

All passwords are stored as plain text files inside the `secrets/` folder at the root of the project. **This folder is never committed to the repository.**

| File | What it contains |
|------|-----------------|
| `secrets/db_password.txt` | WordPress database user password |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/wp_admin_password.txt` | WordPress admin account password |
| `secrets/wp_user_password.txt` | WordPress editor account password |

Non-sensitive configuration (usernames, domain, email addresses) is in `srcs/.env`.

**Default accounts:**

| Account | Username | Role | Password location |
|---------|----------|------|-------------------|
| WordPress admin | `mateferr` | Administrator | `secrets/wp_admin_password.txt` |
| WordPress editor | `wpeditor` | Author | `secrets/wp_user_password.txt` |

To change a password, update the corresponding file in `secrets/` and run `make re` to rebuild the stack.

---

## Check that the services are running correctly

**Show the status of all containers:**
```bash
make ps
```

All three containers (`mariadb`, `wordpress`, `nginx`) should show status `Up`.

**View live logs from all services:**
```bash
make logs
```

Press `Ctrl+C` to stop following the logs.

**Quick connectivity test:**
```bash
curl -sk https://mateferr.42.fr | grep -o '<title>.*</title>'
```

If the stack is running correctly, you should see: `<title>Inception Site</title>`
