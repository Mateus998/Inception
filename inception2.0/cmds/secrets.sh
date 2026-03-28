mkdir -p secrets
printf '%s' '8246' > secrets/db_password
printf '%s' '8246' > secrets/db_root_password
printf '%s' '8246' > secrets/wp_password
printf '%s' '8246' > secrets/wp_adm_password
chmod 600 secrets/*