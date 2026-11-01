# Image for both the `api` (uvicorn) and `worker` (celery) containers.
# Serves: D-004 (one package, two containers), D-001 (Python 3.12), plan §7 (d) (images pin Python 3.12),
#   PLAN §8 BM-07 (uvicorn worker processes, B21).
# Callers: infra/docker-compose.yml services `api` and `worker` (build context apps/api plus the named context
#   `public-page` = apps/public-page, the page renderer B10 depends on by path). Plain docker build:
#   `docker build --build-context public-page=apps/public-page apps/api`.
FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.12.1 /uv /usr/local/bin/uv
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=never PATH="/app/.venv/bin:$PATH"
WORKDIR /app

# The renderer (W01) sits at ../public-page, where uv.lock's path source points (B10).
COPY --from=public-page pyproject.toml README.md /public-page/
COPY --from=public-page agritrace_page /public-page/agritrace_page
# Dependencies first so code edits do not invalidate this layer.
COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --frozen --no-dev --no-install-project
COPY agritrace ./agritrace
COPY alembic ./alembic
COPY alembic.ini ./
COPY config ./config
RUN uv sync --frozen --no-dev

RUN useradd --create-home --uid 10001 app
USER app
EXPOSE 8000
# B21 (Q04-3, BM-07): one uvicorn process saturated one core (CPU-bound in SQLAlchemy/asyncpg/pydantic, not
# waiting on the DB), so the api runs 4 worker processes; uvicorn reads WEB_CONCURRENCY as its --workers
# default, so a deploy sizes it to its vCPUs without a new image (celery ignores it). Each process has its own
# DB pool (5 + 10 overflow): 4 x 15 = 60 connections at most, under Postgres' default 100.
ENV WEB_CONCURRENCY=4
CMD ["uvicorn", "agritrace.main:app", "--host", "0.0.0.0", "--port", "8000"]
