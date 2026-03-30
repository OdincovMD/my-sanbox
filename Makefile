.PHONY: build run enter stop clean rebuild logs status quick dev gui help

NAME := my-sandbox
export UID := $(shell id -u)
export GID := $(shell id -g)

# В новых версиях docker-compose вызывается как "docker compose", 
# но если у вас старый docker-compose, поменяйте алиас ниже.
COMPOSE := docker compose

help:  ## Показать справку
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build:  ## Собрать образ
	$(COMPOSE) build

run:  ## Запустить контейнер в фоне
	$(COMPOSE) up -d

enter:  ## Войти в работающий контейнер
	docker exec -it $(NAME) bash

stop:  ## Остановить контейнер
	$(COMPOSE) stop

clean:  ## Удалить контейнеры, образы и сети
	$(COMPOSE) down --rmi all -v --remove-orphans

rebuild: clean build run  ## Пересобрать всё с нуля

logs:  ## Посмотреть логи
	$(COMPOSE) logs -f

status:  ## Статус контейнера
	$(COMPOSE) ps -a

# Быстрый запуск с автоматическим входом (и удалением после выхода)
quick: build
	$(COMPOSE) run --rm sandbox

# В новой архитектуре dev делает то же самое (тома уже монтируются в docker-compose.yml)
dev: quick

# Для GUI-приложений (проброс уже настроен в docker-compose.yml)
gui: build
	xhost +local:docker
	$(COMPOSE) run --rm sandbox
	xhost -local:docker