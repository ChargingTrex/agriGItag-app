# Local infrastructure

<!-- Purpose: how to run the AgriTrace stack locally and what each piece stands in for in production.
Serves: Arch §Deployment, D-004, D-008, D-009, plan §13 C1. Readers: developers, Verifiers, infra review. -->

## Run

```sh
make up        # docker compose -f infra/docker-compose.yml up -d --build --wait
curl -s localhost:8000/v1/healthz   # {"db":"ok","redis":"ok","s3":"ok"}
make logs      # follow all services
make down      # stop; named volumes db-data and minio-data keep the data
docker compose -f infra/docker-compose.yml down -v   # stop and wipe the data
```

Host-side tools (`uv run alembic ...`, `uv run pytest`) read `apps/api/.env`; copy
`apps/api/.env.example` to start.

## Services and ports

| Service | Image | Host port (override variable) | Notes |
|---|---|---|---|
| `db` | postgis/postgis:16-3.4 | 5432 (`DB_PORT`) | user/password/db `agritrace` |
| `redis` | redis:7-alpine | 6379 (`REDIS_PORT`) | Celery broker |
| `minio` | pgsty/minio (see below) | 9000 S3 API (`MINIO_PORT`), 9001 console (`MINIO_CONSOLE_PORT`) | user/password `minioadmin` |
| `minio-init` | pgsty/mc | — | one-shot, runs `scripts/minio-init.sh`, then exits 0 |
| `mosquitto` | eclipse-mosquitto:2 | 1883 (`MQTT_PORT`) | stub for future sensor feeds; anonymous, dev only |
| `api` | built from `apps/api` | 8000 (`API_PORT`) | uvicorn `agritrace.main:app`; healthy when `/v1/healthz` is all ok |
| `worker` | same image as `api` | — | `celery -A agritrace.worker worker` (D-004, D-009) |

If a port is taken on your machine, remap it without editing the compose file, e.g.
`DB_PORT=5433 API_PORT=8001 make up` (or put the variables in `infra/.env`, which is git-ignored).
`api` and `worker` reach the other services by service name, so remapping host ports does not affect them.

**MinIO image.** The official `minio/minio` and `minio/mc` images can no longer be pulled from Docker Hub
or quay.io (checked 2026-10-29). The compose file and the test fixtures use the pinned community builds
`pgsty/minio` and `pgsty/mc` (same AGPL server and client code). This choice still needs Architect
sign-off under D-008; to switch, change the two `image:` lines and the image in
`apps/api/tests/conftest.py`.

## Buckets (D-008)

`minio-init` creates the buckets on every start; it is idempotent.

| Bucket | Settings | Holds |
|---|---|---|
| `evidence` | object lock on (enabled at creation), versioning on, default retention GOVERNANCE 1 day in dev | Evidence photos, written once through a presigned PUT whose SHA-256 the store verifies (D-011). Never overwritten or deleted by the app. |
| `public-pages` | versioning on, anonymous read (download) | Static public batch pages and their assets, built by the worker (D-007). |
| `id-docs` | private | Farmer identity documents; only reachable through short-lived presigned URLs. Never on public pages. |

Production uses AWS S3 with Object Lock; the retention period and mode (GOVERNANCE or COMPLIANCE) are
set by the infra review, not here. MinIO object-lock semantics differ slightly from AWS.

## Production notes

- HTTP/2, TLS and keep-alive terminate at the ALB / CloudFront; uvicorn speaks HTTP/1.1 behind it.
  Public pages and their assets are cached by CloudFront in front of the `public-pages` bucket.
- The app compresses API responses itself (Brotli, gzip fallback; plan §13 C1), so compression works the
  same locally and behind the load balancer.
- `ENV=prod` refuses to start with the development `JWT_SECRET` or with `OTP_DEV_CODE` set.
- Mosquitto is not part of the pilot deployment.
