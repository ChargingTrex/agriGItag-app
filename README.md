# AgriTrace

Farm-to-consumer traceability for GI-tagged produce. Offline-first Flutter app for farmers, field
officers and QC officers; React portal for FPO admins; FastAPI backend on PostgreSQL/PostGIS; static
public QR pages.

## Five-minute start

```bash
make up            # Postgres+PostGIS, Redis, MinIO, Mosquitto, api, worker
make seed          # demo FPO with three farmers and the reference batch
open http://localhost:8000/docs   # Swagger UI (every field documented)
make test          # backend tests
```

Mobile: `cd apps/mobile && flutter run`. Portal: `cd apps/portal && npm install && npm run dev`.

## Where things are

| Path | What |
|---|---|
| `PLAN.md` | The approved production plan (waves, work packages, gates, benchmarks) |
| `docs/source/` | The four product documents this build follows |
| `DECISIONS.md`, `docs/adr/` | Why things are the way they are (advantages and compromises) |
| `CHECKLIST.md` | Completion status of every work package and gate |
| `TODO.md` | Deferred scope, open questions, debt |
| `docs/agents/` | Agent roles, checkpoint protocol, QA rubric, reviews, audits |
| `docs/api/` | OpenAPI spec, conventions, generated error-code table |
| `docs/LIBRARIES.md` | Every dependency, where it is used and why |

Project status: see the first line of `CHECKLIST.md`.
