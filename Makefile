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

clients: ## Placeholder until B12: prints the client generator commands
	@echo "B12 wires these (D-003):"
	@echo "  npx @openapitools/openapi-generator-cli generate -i packages/openapi/openapi.json -g dart-dio -o apps/mobile/packages/agritrace_api"
	@echo "  npx openapi-typescript packages/openapi/openapi.json -o apps/portal/src/api/schema.d.ts"

seed: ## Placeholder until B12: demo FPO and reference batch
	@echo "make seed: not implemented yet (B12)"

progress: ## Refresh the completion line in CHECKLIST.md
	python3 infra/scripts/checklist-progress.py

error-codes: ## Regenerate docs/api/error-codes.md (CI: add --check); fails on unregistered raised errors
	$(API) uv run python ../../infra/scripts/gen-error-codes.py
