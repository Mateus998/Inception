COMPOSE  = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/mateferr/data

# Build images and start all containers
all:
	@mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

# Build images without starting containers
build:
	$(COMPOSE) build

# Start existing stopped containers (no rebuild)
start:
	$(COMPOSE) start

# Stop running containers (keeps containers and volumes)
stop:
	$(COMPOSE) stop

# Restart all containers
restart:
	$(COMPOSE) restart

# Stop and remove containers (keeps volumes and images)
down:
	$(COMPOSE) down

# Follow logs of all containers (Ctrl+C to exit)
logs:
	$(COMPOSE) logs -f --tail=50

# Show status of all containers
ps:
	$(COMPOSE) ps

# Stop, remove containers and volumes, delete data directory
clean:
	$(COMPOSE) down -v
	sudo rm -rf $(DATA_DIR)

# Full cleanup: containers, volumes, data and all Docker images
fclean: clean
	docker system prune -af

# Full rebuild from scratch
re: fclean all

.PHONY: all build start stop restart down logs ps clean fclean re
