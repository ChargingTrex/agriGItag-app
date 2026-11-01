# Ponytail audit: wave 7 and the 2026-11-01/02 hotfixes (merged tree on `main` @ 4b7d1e6)

Reviewer audit of the code merged after `docs/agents/audits/waves-3-6.md` (commit 283b039), as the role card asks
(docs/agents/roles.md, Reviewer: "at the end of every wave run `/ponytail-audit`"). No code was changed. I read the
code and the tests; I ran no suites (other agents were running them). Every finding was checked against `TODO.md`
§3–§7, the two earlier audits and the per-WP reviews in `docs/agents/reviews/`. What those already track is left out.
Each finding names its owning work package.

| Area | Work packages (file list confirmed with `git log --since=2026-11-01 --name-only` and `git diff 283b039 main`) |
|---|---|
| Backend | B17 (seed `gi_eligible`, test conftest), B18 (presign Content-Length, bounded verify read, privacy lint on build, linter moved), B19 (rules locks `FOR NO KEY UPDATE`, `resolve_flag` lock order), B20 (`retry_later`, audit `reason_code`, nullable farming type), B21 (NUL/int32, per-entry DB-error rejection, telemetry 422, `WEB_CONCURRENCY=4`) |
| Mobile | M13 (free-space purge, Drift v3, camera step), M14 + M16 (strict-order outbox, keystore re-read, JWT `sub` checks, `userChanged`, skew-aware URL expiry), M15 (QC pick-lot) |
| Portal | P09 (`device_in_use` retry, sign-out/refresh), P10 (phone reveal, e2e live mode), P11 (PlotMap test) |
| QA / infra | Q06/Q07 (`qa/robot/**`), `infra/scripts/privacy-lint.py` → symlink, `build_virudhunagar.py` mode bit |

B22 (`rules.check_event` incremental) is still in progress and is not audited here.

**What this repo does:** AgriTrace traces GI-tagged dry chilli from the farm to the consumer. Farmers and officers
log events on an offline-first Flutter app, which syncs to a FastAPI/PostGIS backend. The FPO office works in a React
portal. A published batch gets a static public page behind a QR code.

**Load assumed:** one pilot FPO with a few hundred farmers. Tens of officer and QC phones and a few hundred farmer
phones sync on app open, after each entry and every 15 minutes, often on 2G/3G. The API now runs 4 uvicorn processes
next to one Celery worker; public pages get hundreds of scans a day.

Severity: **P1** = data loss, privacy leak, security hole, or a crash on the farmer's three-tap path. **P2** = a real
defect or scale risk. **P3** = lean, structure, or a small defect.

## Cross-WP checks that came out clean

- **Push trust boundary (B21):** `has_nul`, `le=INT32_MAX`, and `_data_error` (SQLSTATE class 22) reject only the bad
  entry. Deadlocks (40P01/40001) re-raise and become 503 `retry_later`. The entries before them stay committed, and
  the phone's retry gets `duplicate` for them. Tested in `tests/integration/test_sync.py:625` and
  `tests/unit/test_errors.py:129`.
- **Presign (B18):** `Content-Length` is in the signed headers (`tests/unit/test_events_evidence.py:112`). LocalStack
  refuses another length (`tests/integration/test_storage.py:42`). Verify reads at most `size_bytes + 1`. The phone
  sends exactly `bytes.length` (`photo_uploader.dart` `_put`), and its photos stay at or under 350 KB, well below the
  2 MiB ceiling.
- **Reveal (P10):** the endpoint is FPO-admin only and audited, and the number itself is not logged
  (`registry/service.py:1625`). It answers with `Cache-Control: no-store`. The portal keeps the number only in the
  mutation state (`gcTime: 0`) and resets it when the farmer changes.
- **Lock order (B19/B20):** every caller of `run_gate_checks` flushes before it, so `populate_existing` never
  overwrites pending changes (`lots_batches/service.py:804,1026`). The order event → batch → lots by id → flags holds
  for `check_event`, `check_lot`, `create_intake`, `create_batch`, the batch gates and `resolve_flag`. Event-rule and
  lot-rule codes are disjoint, so the event-flag write that comes before the lot lock in `check_event` cannot close a
  cycle. This matches the B20 §3 analysis.
- **`WEB_CONCURRENCY=4`:** the API keeps no per-process state that must be shared. Rate limits live in Valkey
  (scans) and Postgres (OTP). The engine is cached per process, and uvicorn spawns its workers. Celery uses NullPool,
  one connection per task. The connection budget in the Dockerfile comment (4 × 15 + Celery concurrency ≤ 100) is
  right. The worker image inherits the variable, and Celery ignores it.
- **Retries vs idempotency (mobile, portal):** a 503 `retry_later` and a 401 put the phone's batch into backoff.
  They do not mark it `needs_attention` (`retry.dart` `classify`). The portal's `device_in_use` retry is safe
  because the server raises the 409 before the OTP is committed as used: `consumed_at` is set but rolled back
  (`identity/service.py:571-579`).
- **Privacy lint on build (B18):** `privacy_hits` reports the file, the line and the rule, never the matched text. A
  hit fails the build before anything is written (`tests/integration/test_publishing.py:404`).

## Should fix

1. **[WP-Q06] P2: the Robot publishing suite writes every user's phone number into its committed reports**
   (`qa/robot/api/publishing.robot:30-35`; `qa/robot/lib/agritrace_keywords.py:388-395` `new_phone`; committed
   `docs/agents/qa/Q06/robot/output.xml`, 24 numbers, and `docs/agents/qa/Q07/robot/output.xml`, 14)
   - **What this is:** "Page HTML Has No Phone Survey Number Or Temp Uploads" checks that no user's phone appears on
     the published page.
   - **Problem:**
     - It runs `Query SELECT phone FROM users`. DatabaseLibrary logs the full result table at INFO, and the next
       `Evaluate` logs `${phones}` and `${leaks}` again. A failure message (`msg=${name} leaks ${hits}`) would print
       the matched numbers a third time.
     - Today these are the seed's `+91900000xxxx` numbers plus `new_phone()`'s random `+9197xxxxxxxx`. The random
       ones are real-format mobile numbers that may belong to strangers, and they now sit in git. Point
       `DB_HOST` at a stack with pilot data (G5 or staging), and every farmer's phone lands in `output.xml`,
       `log.html` and `report.html`, which Verifiers commit under `docs/agents/qa/`.
     - The brief for QA code says no phone numbers in logs or reports (CLAUDE.md §6).
   - **Fix:**
     - Move the comparison into one Python keyword in `agritrace_keywords.py`, for example
       `Page Leaks Any User Phone    ${name}`. It runs the query itself and returns only the count of hits, so
       nothing is logged.
     - Change the failure message to `${name} leaks ${n} known values`.
     - Draw `new_phone()` from the seed's own `+9190000…` block (say `+919000` plus 6 random digits), so committed
       logs hold demo numbers only.
     - Regenerate or strip the two `output.xml` files at the next Q run.
   - **If we skip it:** the first live Robot run against real data publishes the farmer phone list inside a QA
     report.

## Nice to have

2. **[WP-B21] P3: a NUL in any REST body still answers 500, while the sync push has two guards for the same thing**
   (`apps/api/agritrace/core/errors.py:597-620` `_db_error`; `modules/events/service.py:903-918` `_data_error`,
   `:1021-1023`; `core/schemas.py:23-47` `has_nul`)
   - **What this is:** B21 made data Postgres refuses (NUL, out of range) a per-entry `validation_error` on
     `POST /v1/sync/push` only.
   - **Problem:**
     - `POST /v1/flags/{id}/resolve` with `note: "a\u0000b"` (or `POST /v1/farmers` with a NUL in `name`) reaches
       Postgres. Postgres raises 22021. `_db_error` hands it to `_unhandled`, so the answer is 500 `internal_error`
       plus a traceback log line. The Q04/Q05 fuzz runs covered only `/v1/sync/push` and `/v1/intakes`.
     - In the push, `has_nul` (25 lines) is redundant. `test_sync.py:650-653` switches it off and shows that
       `_data_error` gives the same per-entry rejection (the B21-r1 probe: NUL text → 22021, NUL jsonb → 22P05).
   - **Fix:**
     - Move `_data_error`'s test (`sqlstate.startswith("22")`) into `core/errors.py`. `_db_error` then answers 422
       `validation_error` for class 22, and the push keeps calling the same helper for its per-entry rejection.
     - Delete `has_nul` and its check in `push`; the detail `type` becomes `db_data_error`.
     - Keep `NoNulStr` on the telemetry fields: their 422 for the whole envelope is the documented rule.
   - **If we skip it:** fuzzing any other endpoint finds 500s, and two code paths guard one rule.

3. **[WP-B19] [WP-B16] P3: a rules task that hits a database error is dropped, though D-009 says checks retry**
   (`apps/api/agritrace/modules/rules_flags/tasks.py:33-36,64,84`; `worker/__init__.py:33`)
   - **What this is:** `rules.check_event`, `check_lot` and `check_plot` recompute flags after each push or photo
     verify. Their D-009 comment says "checks retry with the worker, not the phone".
   - **Problem:**
     - The tasks have no `autoretry_for`. With `task_acks_late=True`, a task that raises is still acknowledged (the
       Celery default), so it never runs again.
     - B19 makes these tasks wait on row locks, which makes such failures more likely. So do a Postgres restart
       during a deploy and a connection reset. Event-rule flags (`event_off_plot`, `photo_checksum_mismatch`,
       `exif_mismatch`, `clock_skew`, `gps_poor_accuracy`) are computed only in `check_event`; the gates re-run lot
       and batch rules, not event rules. So a lost run means the reviewer never sees that warning for that event.
     - They are WARN flags and the gates still re-check holds, so this is P3.
   - **Fix:** add `autoretry_for=(DBAPIError,), retry_backoff=True, max_retries=5` to the three task decorators, as
     `publishing/tasks.py:22-24` does for S3. The tasks are idempotent by `dedupe_key`. One unit test: a fake
     `run_db_task` that raises `DBAPIError` once must cause a retry.
   - **If we skip it:** now and then a tampered or off-plot photo carries no flag, and nobody notices.

4. **[WP-B03] [WP-B18] P3: the ID-document presigned PUT still has no size bound**
   (`apps/api/agritrace/modules/registry/service.py:1413-1415`; `registry/schemas.py:573-583` `IdDocumentIn`)
   - **What this is:** B18 signed `Content-Length` for evidence photos. The same `storage.presign_put` also signs
     uploads into the private `id-docs` bucket.
   - **Problem:** `IdDocumentIn` has no `size_bytes`, and the call passes none. A signed-in officer with a farmer's
     consent can declare the SHA-256 of a file of any size and upload it, up to S3's 5 GB single-PUT limit. That is
     the hole waves 3–6 #4 closed for the evidence bucket. No client calls this endpoint yet, so the contract is
     cheap to change now.
   - **Fix:** add `size_bytes: int = Field(gt=0, le=MAX_PHOTO_BYTES, …)` to `IdDocumentIn`, pass
     `size_bytes=body.size_bytes` to `presign_put`, then run `make openapi` and `make clients`. Extend the existing
     storage test to cover this caller too.
   - **If we skip it:** storage cost and abuse exposure stay open on one bucket after they were closed on the other.

5. **[WP-Q06] P3: Robot creates random real-format numbers as users, which would send OTP SMS to strangers on a stack without the dev code**
   (`qa/robot/lib/agritrace_keywords.py:277-300` `_sign_in`, `:388-395` `new_phone`)
   - **What this is:** `_sign_in` calls `/auth/otp/request` and then verifies with `OTP_DEV_CODE`, defaulting to
     `123456`.
   - **Problem:** on a stack without `OTP_DEV_CODE`, every sign-in of a `new_farmer()` makes a real SMS go to a
     random `+9197…` number (`identity/service.py:440-441`). The verify then fails, after the SMS has already gone.
   - **Fix:** the `+919000…` block from finding 1. Also have `_sign_in` fail first when `OTP_DEV_CODE` is not set in
     the Robot environment, with no request sent.
   - **If we skip it:** one misconfigured run texts strangers, and the SMS provider bills for it.

Left out: nothing beyond what TODO.md, the earlier audits and the per-WP reviews already track. Two of those are
touched by this wave:
- TODO §6 P2: two isolates refresh at the same moment.
- TODO §7: publish answers 202 before the build succeeds.

## Verdict for wave 7

**No P1.** One P2 (finding 1, QA code, privacy) and four P3s. Nothing here blocks G3, G4 or G5 on code grounds. Fix
finding 1 before any Robot run touches a database that holds pilot data.

**Did the earlier audits' P1 fixes introduce new risks?**
- **M14 (strict FIFO, D-054):** this does what it should. The cost is that one entry the server keeps answering with
  a 5xx now holds back every later entry of that user, and there is no attempt cap. B21 removed the 5xx causes that
  are known per entry (NUL, int32, data errors). The remaining ones are transient races, and a retry turns them into
  `duplicate` or a 4xx. So I found no concrete case, but Q01 should watch for a cloud indicator that stays stuck.
- **M14 (keystore re-read) and M16 (`userChanged`, the JWT `sub` checks in `_adoptStored` and `AuthInterceptor`,
  skew-aware expiry):** these are tight and tested (`session_test.dart:203,221`, `interceptor_test.dart:121`,
  `robustness_test.dart`). The simultaneous cross-isolate refresh stays the open TODO §6 P2.
- **P09:** this adds one deliberate behaviour. A sign-out without network keeps the session and shows "Could not sign
  out". It is visible, it is documented, and only the server can clear the httpOnly cookie anyway.
- **B18 (the waves-3-6 P2 fix):** this is the one that widens an existing risk. Free text now fails the page build
  through the linter, for example a processor address typed with a landline. That is a new, user-triggered way into
  the TODO §7 case "publish answers 202 and marks the batch published before the page build succeeds": the QR is
  printed and the page is missing. Raise that line to P2 and decide it before G4/G5.

Lean: about -25 lines possible (finding 2: `has_nul` and its check go, `_data_error` moves into core), -0 dependencies.

Not checked:
- I ran no suites, builds or devices. Lock order and the retry behaviour come from reading the code.
- B22 is unmerged.
- Only skimmed: `qa/robot/portal/portal.robot`, most of `apps/portal/e2e/chain.spec.ts`, `PlotMap.test.tsx`, the
  MSW handlers, and the Drift v3 migration body (M13 had its own MOB/SEC review).
- iOS behaviour: the free-space check is Android-only by D-053.
- Real AWS S3 enforcement of a signed `Content-Length`; only LocalStack is tested.
