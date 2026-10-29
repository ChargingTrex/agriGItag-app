"""Domain modules of the modular monolith; each may import another only via `models` and `service`.

Serves: D-004 (import-linter contracts in apps/api/pyproject.toml).
Callers: `agritrace.main` (router discovery), `agritrace.worker` (task discovery), `alembic/env.py`.
"""
