# Inception (42) — Relatório de Implementação

> Objetivo: registrar decisões, comandos, estrutura e teoria para montar o README e estudar para a defesa.

## 0) Contexto
- Data de início:
- Ambiente: (WSL / Linux / macOS)
- Versões:
  - Docker:
  - Docker Compose:
- Domínio usado (ex.: login.42.fr / localhost):
- Pasta de dados persistentes (ex.: /home/<user>/data):

---

## 1) Requisitos do subject (checklist)
- [ ] Nginx com TLS
- [ ] WordPress + PHP-FPM
- [ ] MariaDB
- [ ] Volumes persistentes
- [ ] Rede dedicada
- [ ] Sem “images prontas” que burlem o objetivo (conforme subject)
- [ ] Restart policies / healthchecks (se aplicável)

> Notas do subject (cole aqui trechos importantes):

---

## 2) Arquitetura (visão geral)
### 2.1 Diagrama (texto)
- Internet/Browser
  -> Nginx (443/TLS termination)
  -> WordPress (php-fpm)
  -> MariaDB

### 2.2 Redes Docker
- `frontend`:
- `backend`:

### 2.3 Volumes
- `mariadb_data` -> host path:
- `wordpress_data` -> host path:
- Certificados -> host path:

---

## 3) Estrutura de diretórios do repositório
```text
srcs/
  docker-compose.yml
  .env
  requirements/
    nginx/
      Dockerfile
      conf/
      tools/
    wordpress/
      Dockerfile
      conf/
      tools/
    mariadb/
      Dockerfile
      conf/
      tools/
```

---

## 4) Variáveis de ambiente (.env)
### 4.1 Lista e propósito
- `DOMAIN_NAME=` …
- `MYSQL_DATABASE=` …
- `MYSQL_USER=` …
- `MYSQL_PASSWORD=` …
- `MYSQL_ROOT_PASSWORD=` …
- `WP_ADMIN_USER=` …
- `WP_ADMIN_PASSWORD=` …
- `WP_ADMIN_EMAIL=` …
- `WP_USER=` …
- `WP_USER_PASSWORD=` …
- `WP_USER_EMAIL=` …

### 4.2 Regras de segurança
- O que não commitar:
- Estratégia para segredos:

---

## 5) Implementação por serviço (comandos + arquivos + teoria)

### 5.1 MariaDB
**Objetivo do serviço:**
- …

**Arquivos:**
- `srcs/requirements/mariadb/Dockerfile`
- `srcs/requirements/mariadb/tools/entrypoint.sh`
- `srcs/requirements/mariadb/conf/...` (se houver)

**Comandos usados:**
```bash
# build/up
docker compose up -d --build mariadb

# logs
docker compose logs -f mariadb
```

**Teoria (curto):**
- Por que volume é obrigatório:
- O que o entrypoint inicializa:
- Como garantir idempotência:

**Checklist de validação:**
```bash
docker compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"
```

---

### 5.2 WordPress (PHP-FPM)
**Objetivo do serviço:**
- …

**Arquivos:**
- `srcs/requirements/wordpress/Dockerfile`
- `srcs/requirements/wordpress/tools/entrypoint.sh`

**Comandos usados:**
```bash
docker compose up -d --build wordpress
docker compose logs -f wordpress
```

**Teoria (curto):**
- Diferença Nginx vs PHP-FPM:
- wp-cli: por que usar e como automatizar:
- Volume do `/var/www/html`:

**Checklist de validação:**
```bash
docker compose exec wordpress php -v
docker compose exec wordpress wp --info --allow-root
```

---

### 5.3 Nginx (TLS)
**Objetivo do serviço:**
- …

**Arquivos:**
- `srcs/requirements/nginx/Dockerfile`
- `srcs/requirements/nginx/conf/nginx.conf`
- Certs: path …

**Comandos usados:**
```bash
docker compose up -d --build nginx
docker compose logs -f nginx
curl -kI https://<dominio>
```

**Teoria (curto):**
- TLS termination:
- HTTP->HTTPS redirect:
- fastcgi_pass (como Nginx fala com PHP-FPM):

**Checklist de validação:**
```bash
curl -kI https://<dominio>
```

---

## 6) Fluxo padrão de operação (cola rápida)
### Subir tudo
```bash
docker compose up -d --build
```

### Ver status
```bash
docker compose ps
```

### Logs
```bash
docker compose logs -f --tail=200
```

### Derrubar (sem apagar dados)
```bash
docker compose down
```

### Derrubar (apagando dados) — cuidado
```bash
docker compose down -v
```

---

## 7) Debugging (erros e soluções)
> Registre no formato: Sintoma -> Causa -> Solução -> Como prevenir

### Caso 1: Nginx 502
- Sintoma:
- Causa:
- Solução:
- Comandos:
```bash
docker compose logs nginx
docker compose logs wordpress
```

### Caso 2: WordPress não conecta no DB
- …

---

## 8) Perguntas de defesa (Q&A)
### 8.1 Docker
- Q: Diferença entre imagem e container?
  - A:
- Q: O que é volume nomeado vs bind mount?
  - A:
- Q: O que é network bridge?
  - A:

### 8.2 Stack
- Q: Por que Nginx precisa de TLS?
  - A:
- Q: Por que separar WordPress e MariaDB?
  - A:
- Q: Como você garante persistência?
  - A:

---

## 9) Checklist final de entrega
- [ ] `docker compose up -d --build` funciona do zero
- [ ] HTTPS ok
- [ ] Persistência confirmada (down/up sem perder DB/wp)
- [ ] Sem portas expostas indevidas
- [ ] README pronto