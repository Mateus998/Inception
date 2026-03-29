NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml
LOGIN = $(shell whoami)
DATA_PATH = /home/$(LOGIN)/data
DB_PATH = $(DATA_PATH)/mariadb
WP_PATH = $(DATA_PATH)/wordpress

all: set_login up

set_login:
	grep -v '^LOGIN=' srcs/.env > tmp.env
	echo "LOGIN=$(LOGIN)" >> tmp.env
	mv tmp.env srcs/.env

up: create_dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart: down up

build:
	$(COMPOSE) build

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

create_dirs:
	mkdir -p $(DB_PATH)
	mkdir -p $(WP_PATH)

fclean: down
	sudo rm -rf $(DB_PATH)/*
	sudo rm -rf $(WP_PATH)/*

re: fclean up

.PHONY: all up down start stop restart build logs ps create_dirs set_login fclean re