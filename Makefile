COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/mateferr/data

all:
	@mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v
	@rm -rf $(DATA_DIR)

fclean: clean
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re
