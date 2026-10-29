"""AgriTrace API package: one modular monolith served as two containers (api, worker).

Serves: Arch §Backend services, D-001 (Python/FastAPI), D-004 (modular monolith).
Callers: uvicorn (`agritrace.main:app`), Celery (`-A agritrace.worker`), Alembic env, tests.
"""
