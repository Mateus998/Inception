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
  srcs/requirements/mariadb/tools/init.sh \
  srcs/requirements/wordpress/conf/wordpress.cnf \
  srcs/requirements/wordpress/tools/init.sh \
  srcs/requirements/nginx/conf/nginx.cnf \
  srcs/requirements/nginx/tools/init.sh

chmod +x srcs/requirements/*/tools/init.sh