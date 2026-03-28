# Base image: Debian Bookworm (stable Debian release)
FROM debian:bookworm                          

RUN apt-get update && apt-get install -y --no-install-recommends \
# Install MariaDB server (mysqld)
mariadb-server \                          
# Install MariaDB client tools (e.g., mysql CLI)
mariadb-client \                          
# Install CA certs (useful for TLS downloads/verification)
ca-certificates \                         
# Clean apt cache to reduce image size
&& rm -rf /var/lib/apt/lists/*              

# Create runtime dir for mysqld socket/pid and the data directory
RUN mkdir -p /run/mysqld /var/lib/mysql \     
# Ensure MariaDB user owns these dirs (permissions)
&& chown -R mysql:mysql /run/mysqld /var/lib/mysql  

# Override/extend MariaDB server configuration
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf  
# Add custom entrypoint script (init DB/users, etc.)
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh     

# Document that the container listens on MariaDB port 3306
EXPOSE 3306                                   

# Run your entrypoint first (usually for initialization)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]   
# Default command: start the MariaDB server process
CMD ["mysqld"]                                 