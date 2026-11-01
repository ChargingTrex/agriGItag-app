# AgriTrace

Farm-to-consumer traceability for GI-tagged produce. Offline-first Flutter app for farmers, field
officers and QC officers; React portal for FPO admins; FastAPI backend on PostgreSQL/PostGIS; static
public QR pages.

## Five-minute start

You need Docker (Compose v2), [uv](https://docs.astral.sh/uv/) (it fetches Python 3.12), Node ≥ 24.15 with npm,
and Flutter 3.38.4. Java 11+ is needed only for `make clients`.

```bash
make up            # Postgres+PostGIS, Valkey, LocalStack S3, Mosquitto, api, worker (waits until healthy)
make seed          # migrate the DB, then the demo FPO with three farmers and the reference batch
open http://localhost:8000/docs   # Swagger UI (every field documented)
make test-unit     # backend unit tests, no Docker needed (~2 min)
make test          # every backend test; integration tests start their own containers (Docker)
```

Port taken (for example a local Postgres on 5432)? Put `DB_PORT=5433` (or `REDIS_PORT`, `S3_PORT`, `API_PORT`)
in `infra/.env`, which is git-ignored. For host-side tools, `cp apps/api/.env.example apps/api/.env` and
change the port in `DATABASE_URL`. See `infra/README.md`.

- Portal: `cd apps/portal && npm ci && npm run dev`, then open http://localhost:5173. Sign in as the seeded
  FPO admin `9000000001` with code `123456`; the first sign-in chooses the PIN. `npm run dev:mock` needs no
  stack.
- Mobile: `cd apps/mobile && flutter pub get && flutter run -t lib/main_dev.dart` (an Android emulator
  reaches the API at 10.0.2.2:8000). See `apps/mobile/README.md`.
- After an API change: `make openapi && make clients`. `make clients` needs Java 11+; set `JAVA_HOME` if
  `java` is older (see the Makefile).

## Where things are

| Path | What |
|---|---|
| `PLAN.md` | The approved production plan (waves, work packages, gates, benchmarks) |
| `docs/source/` | The four product documents this build follows |
| `DECISIONS.md`, `docs/adr/` | Why things are the way they are (advantages and compromises) |
| `CHECKLIST.md` | Completion status of every work package and gate |
| `TODO.md` | Deferred scope, open questions, debt |
| `docs/agents/` | Agent roles, checkpoint protocol, QA rubric, reviews, audits |
| `docs/api/` | API conventions, generated error-code table |
| `packages/openapi/openapi.json` | Generated OpenAPI spec (D-003) |
| `docs/LIBRARIES.md` | Every dependency, where it is used and why |

Project status: see the `Completion:` line at the top of `CHECKLIST.md`.
