.PHONY: help install test install-fixit-react-spa test-fixit-react-spa dev-fixit-react-spa install-fixit-api-backend test-fixit-api-backend dev-fixit-api-backend install-prometheus-grafana test-prometheus-grafana dev-prometheus-grafana up down logs ps db-wait db-schema seed db-reset
# Generated from the repository plan. `make help` lists the targets.
.DEFAULT_GOAL := help

install-fixit-react-spa: ## install fixit-react-spa
	cd apps/fixit-react-spa && npm ci

test-fixit-react-spa: ## test fixit-react-spa
	cd apps/fixit-react-spa && npm test

dev-fixit-react-spa: ## run fixit-react-spa locally
	cd apps/fixit-react-spa && npm run dev

install-fixit-api-backend: ## install fixit-api-backend
	cd services/fixit-api-backend && mvn -q -DskipTests package

test-fixit-api-backend: ## test fixit-api-backend
	cd services/fixit-api-backend && mvn -q test

dev-fixit-api-backend: ## run fixit-api-backend locally
	cd services/fixit-api-backend && mvn spring-boot:run

install-prometheus-grafana: ## install prometheus-grafana
	cd services/prometheus-grafana && mvn -q -DskipTests package

test-prometheus-grafana: ## test prometheus-grafana
	cd services/prometheus-grafana && mvn -q test

dev-prometheus-grafana: ## run prometheus-grafana locally
	cd services/prometheus-grafana && mvn spring-boot:run

install: install-fixit-react-spa install-fixit-api-backend install-prometheus-grafana ## install every component

test: test-fixit-react-spa test-fixit-api-backend test-prometheus-grafana ## test every component

up: ## start the local platform (containers)
	[ -f .env ] || cp .env.example .env
	docker compose up -d

down: ## stop the local platform
	docker compose down

logs: ## follow the platform logs
	docker compose logs -f

ps: ## what is running
	docker compose ps

db-wait:
	@until docker compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done

db-schema: db-wait ## load the LLD schema (db/schema.sql) — until a service ships its own migrations
	docker compose exec -T postgres psql -U postgres -d app -v ON_ERROR_STOP=1 -q < db/schema.sql

seed: db-wait ## load synthetic seed rows (db/seed.sql) — local only
	docker compose exec -T postgres psql -U postgres -d app -v ON_ERROR_STOP=1 -q < db/seed.sql

db-reset: db-wait ## drop and recreate the local database, then schema + seed
	docker compose exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q -c 'DROP DATABASE IF EXISTS app WITH (FORCE)' -c 'CREATE DATABASE app'
	$(MAKE) db-schema seed

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-32s %s\n", $$1, $$2}'
