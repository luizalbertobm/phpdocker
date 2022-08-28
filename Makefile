COMPOSER=docker-compose exec -w /app php-fpm composer

.PHONY: help
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker
up: ## Build and start docker containers
	docker-compose up -d --build

down: ## Stop and remove orphans containers
	docker-compose down --remove-orphans

ps: ## List all running services
	docker-compose ps

## —— PHP
php-sh: ## Shell into the PHP container
	docker-compose exec php-fpm bash

php-exec: ## Execute a command in PHP container. Eg.: make php-exec c="php -v"
	@$(eval c ?=)
	docker-compose exec php-fpm $(c)

## —— Database
db-sh: ## Open a mysql console
	docker-compose exec database mysql -uroot -proot

## —— Symfony
sf-console: ## Run symfony console
	@$(eval c ?=)
	docker-compose exec php-fpm bin/console $(c)

sf-cache-clear: ## Remove symfony cache directory
	docker-compose exec php-fpm rm -R ./cache

sf-init: ## Initialize symfony project. Eg.: make sf-init v="5.*"
	@$(eval v ?=)
	rm -rf code/*
	$(COMPOSER) create-project symfony/skeleton:"$(v)" .
	rm -rf .git



## —— Composer
composer-i: ## Install composer dependencies
	$(COMPOSER) install

composer-u: ## Update composer dependencies
	$(COMPOSER) update

composer-r: ## Add a new dependency for the project. Eg.: composer-r c=<dependency-slug>
	@$(eval c ?=)
	$(COMPOSER) req $(c)

CURRENT := $(git branch --show-current)
git-branch-rename:
	@$(eval name ?=)
	git branch -m $(name)