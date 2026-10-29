# Local infrastructure

<!-- Purpose: how to run the AgriTrace stack locally and what each piece stands in for in production.
Serves: Arch §Deployment, D-004, D-008, D-009, D-021, plan §13 C1. Readers: developers, Verifiers, infra review. -->

## Run

```sh
make up        # docker compose -f infra/docker-compose.yml up -d --build --wait
curl -s localhost:8000/v1/healthz   # {"db":"ok","redis":"ok","s3":"ok"}
curl -sI localhost:8000/v1/healthz  # HEAD: the mobile reachability probe
make logs      # follow all services
make down      # stop; the db-data volume keeps the database
docker compose -f infra/docker-compose.yml down -v   # stop and wipe the database
```

Host-side tools (`uv run alembic ...`, `uv run pytest`) read `apps/api/.env`; copy
`apps/api/.env.example` to start.

## Services and ports

| Service | Image | Host port (override variable) | Notes |
|---|---|---|---|
| `db` | postgis/postgis:16-3.4 | 5432 (`DB_PORT`) | user/password/db `agritrace` |
| `valkey` | valkey/valkey:8-alpine | 6379 (`REDIS_PORT`) | Celery broker and cache, Redis protocol (D-021) |
| `s3` | localstack/localstack:4.14.0, `SERVICES=s3` | 4566 (`S3_PORT`) | S3 stand-in (D-008); credentials `test`/`test`, region ap-south-1 |
| `s3-init` | amazon/aws-cli | — | one-shot, runs `scripts/s3-init.sh` once `s3` is healthy, then exits 0 |
| `mosquitto` | eclipse-mosquitto:2 | 1883 (`MQTT_PORT`) | stub for future sensor feeds; anonymous, dev only |
| `api` | built from `apps/api` | 8000 (`API_PORT`) | uvicorn `agritrace.main:app`; healthy when `/v1/healthz` is all ok |
| `worker` | same image as `api` | — | `celery -A agritrace.worker worker` (D-004, D-009) |

If a port is taken on your machine, remap it without editing the compose file, e.g.
`DB_PORT=5433 API_PORT=8001 make up` (or put the variables in `infra/.env`, which is git-ignored).
`api` and `worker` reach the other services by service name, so remapping host ports does not affect them.

**Valkey, not Redis (D-021).** Redis 7.4+ images are RSAL/SSPL-licensed; Valkey is the BSD-3 fork with the
same protocol. `REDIS_URL`, the `redis` Python client and Celery's redis transport are unchanged.
Production uses ElastiCache for Valkey.

**LocalStack version.** `localstack/localstack:latest` (2026.x) exits at start-up with
"License activation failed" unless `LOCALSTACK_AUTH_TOKEN` is set. The stack therefore pins 4.14.0, the
last release that runs without a token (frozen, Feb 2026). To use a newer image, set a token from a
LocalStack account and change the tag. The community image keeps no data across restarts, and
`s3-init` recreates the buckets on every start.

## Two S3 endpoints

- `S3_ENDPOINT` is what the API and worker call: `http://s3:4566` inside compose.
- `S3_PUBLIC_ENDPOINT` is what phones and browsers reach. Presigned upload URLs are built against it:
  `http://localhost:<S3_PORT>` by default. For a phone on the same Wi-Fi, set it to the laptop's LAN
  IP. In production both are the AWS S3 endpoint.

## Buckets (D-008)

`s3-init` creates the buckets; it is idempotent.

| Bucket | Settings | Holds |
|---|---|---|
| `evidence` | object lock on (enabled at creation), versioning on, default retention GOVERNANCE 1 day in dev | Evidence photos, written once through a presigned PUT whose SHA-256 the store verifies (D-011). Never overwritten or deleted by the app. |
| `public-pages` | versioning on, bucket policy allowing anonymous `s3:GetObject` | Static public batch pages and their assets, built by the worker (D-007). |
| `id-docs` | private, public access block on | Farmer identity documents; only reachable through short-lived presigned URLs. Never on public pages. |

Production uses AWS S3 with Object Lock; the retention period and mode (GOVERNANCE or COMPLIANCE) are
set by the infra review, not here. LocalStack does not enforce IAM or bucket policies by default, so the
policies above are documentation of intent locally and are enforced only on AWS.

## Production notes

- HTTP/2, TLS and keep-alive terminate at the ALB / CloudFront; uvicorn speaks HTTP/1.1 behind it.
  Public pages and their assets are cached by CloudFront in front of the `public-pages` bucket.
- The app compresses API responses itself (Brotli, gzip fallback; plan §13 C1), so compression works the
  same locally and behind the load balancer.
- `ENV=prod` refuses to start with the development `JWT_SECRET` or with `OTP_DEV_CODE` set.
- Mosquitto is not part of the pilot deployment.
