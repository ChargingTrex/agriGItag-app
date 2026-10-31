# Developer and CI entry points for AgriTrace.
# Serves: CLAUDE.md §8 (commands), plan §7.1 B00. Callers: developers, CI, Verifiers.
# Backend targets run inside the apps/api uv environment (`uv sync` once first).

COMPOSE := docker compose -f infra/docker-compose.yml
API := cd apps/api &&

.PHONY: up down logs test test-unit lint openapi clients seed progress error-codes

up: ## Build and start the stack, wait until every service is healthy
	$(COMPOSE) up -d --build --wait

down: ## Stop the stack (named volumes are kept; add -v by hand to wipe data)
	$(COMPOSE) down

logs: ## Follow logs of all services
	$(COMPOSE) logs -f

test: ## All backend tests (integration tests need Docker)
	$(API) uv run pytest

test-unit: ## Backend unit tests, no Docker needed
	$(API) uv run pytest tests/unit

lint: ## ruff + ruff format --check + mypy + import-linter (D-004) + interrogate (100 % docstrings)
	$(API) uv run ruff check . && uv run ruff format --check . && uv run mypy agritrace && uv run lint-imports && uv run interrogate agritrace

openapi: ## Regenerate packages/openapi/openapi.json
	$(API) uv run python -m agritrace.export_openapi

# Needs Java 11+ for openapi-generator (locally: JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
# make clients), Dart, and `npm ci` once in apps/portal. Run `make openapi` first when the API changed.
clients: ## Regenerate the Dart (dart-dio) and TS (openapi-typescript) clients from packages/openapi/openapi.json (D-003)
	apps/mobile/tool/gen_api.sh
	cd apps/portal && npm run gen:api

seed: ## Migrate the stack DB, then seed the demo FPO and the PRD §12 reference batch FGP8T4033HM7 (idempotent)
	$(COMPOSE) exec api sh -c "alembic upgrade head && python -m agritrace.seed.demo"

progress: ## Refresh the completion line in CHECKLIST.md
	python3 infra/scripts/checklist-progress.py

error-codes: ## Regenerate docs/api/error-codes.md (CI: add --check); fails on unregistered raised errors
	$(API) uv run python ../../infra/scripts/gen-error-codes.py
