<!-- Purpose: G5 SEC review, an OWASP ASVS 4.0.3 Level 1 checklist over identity, sync, presigned URLs, tenant
scoping and public pages, in one document. Serves: PLAN.md §10 step 4 (G5 extras), §3 G5, CLAUDE.md §6, TODO.md
line 97 (DPDP, "Owner: SEC review before G5") and line 120 (B02 P3s, "pick up in the SEC pass before G5").
Readers: Orchestrator, Architect-Gate (G5 sign-off), QA Lead. -->

# SEC review for G5: OWASP ASVS 4.0.3 Level 1

- **Reviewer:** SEC Reviewer (Opus), read-only on code
- **Date:** 2026-11-02
- **Tree:** `main` @ `4b7d1e6`
- **Method:** I read the code, mostly in `apps/api/agritrace`, plus `apps/public-page`, the portal `src/auth`,
  the mobile `core/router/session.dart` and `core/capture`, and `infra/`. I ran one OpenAPI scan to find every
  operation without a security requirement. I sampled 17 routes across 9 modules for FPO scoping. I did not
  run a pentest, a DAST scan or a dependency audit.
- **Verdict: FAIL. 2 FAILs, which become G5 P1s. 16 PARTIAL. The rest PASS or N/A.**
  - **P1-1 (ASVS 3.3.2).** A refresh token never needs re-authentication. There is no idle or absolute
    lifetime, and no endpoint revokes a lost phone's device.
  - **P1-2 (ASVS 8.3.2).** A data principal cannot have their data erased or exported, and no runbook covers
    it (DPDP, TODO.md:97).

  Both fixes are small; see "P1 list for G5" at the end. Every other gap is a PARTIAL with a one-line fix and
  an owner.

Legend: **PASS** = met, with evidence. **PARTIAL** = met in part, or met only through production
infrastructure that is not in the repo yet. **FAIL** = an L1 requirement is not met. **N/A** = it does not
apply here, with the reason.

## V2 Authentication (OTP, PIN, devices, tokens)

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 2-1 | 2.7.2 | OTP expires within 10 min | PASS | `OTP_TTL = 5 min`, `modules/identity/service.py:104`. Expiry is checked in `otp_outcome`, `service.py:172-192`. | — |
| 2-2 | 2.7.3 | OTP single use | PASS | Only the newest challenge counts, taken `FOR UPDATE`, and a consumed one is refused: `service.py:546-555`. `consumed_at` is set on success: `service.py:571`. | — |
| 2-3 | 2.7.4 / 2.9.x | OTP from a CSPRNG, stored only as a hash | PASS | `secrets.randbelow(10**6)`, `service.py:127`. The stored value is an HMAC-SHA256 of `phone:code` under a key derived from `JWT_SECRET` with the label `agritrace-otp-v1` (`service.py:143-148`), which closes B02 P3-1. The comparison is `hmac.compare_digest`, `service.py:559`. | — |
| 2-4 | 2.2.1 | Anti-automation on OTP | PARTIAL | Per phone: 1 code per 60 s and `OTP_DAILY_CAP` (10) per 24 h (`service.py:105-106, 151-169, 425-434`), and 5 guesses per challenge (`service.py:107, 185-192`), so at most 50 guesses a day. There is **no per-IP limit**, so an attacker can burn a victim's daily cap and lock them out for 24 h (B02-r2 P3). The cap check also races (`shortcut:` at `service.py:423`). | Add a per-IP Valkey budget on `otp/request`, reusing `reporting.limit_scans`'s pattern. Owner: B02 follow-up. |
| 2-5 | 2.7.1 | SMS is a NIST "restricted" authenticator | PARTIAL (needs risk acceptance) | SMS OTP is the only first factor, as PRD FR1 requires for feature phones. Office roles add a PIN (`needs_pin`, `service.py:328`). | Architect-Gate: record the ASVS 2.7.1 deviation in D-024 "Consequences". No code change. |
| 2-6 | 2.2.1 / 2.5 | PIN lockout | PASS | 5 wrong PINs lock the account for 5 minutes (`service.py:108-109, 195-218`). The user row is locked while the PIN is checked (`_check_pin`, `service.py:591-620`), and the hash is Argon2id (`service.py:115, 221-246`). The PIN alone guards nothing: OTP comes first. Optional escalating lock: B02 P3-13 (open, optional). | — |
| 2-7 | 2.7.6 / 3.x | Dev bypass code only outside prod | PASS | `otp_dev_code` has no default, and an empty value counts as off (`core/config.py:54-56, 71-82`). `ENV=prod` refuses to start with it, with a `JWT_SECRET` under 32 bytes, or without a real SMS provider (`config.py:84-101`). `config.py:27` sets `ENV` to `dev` by default; see 14-4. | — |
| 2-8 | 2.2 / D-005 | Device binding and `device_in_use` | PASS | `_bind_device` locks the device row and refuses a device signed in for another user with `DeviceInUseError` (409), so knowing a device id does not let someone sign its owner out (`service.py:444-472`). Every request re-reads the device row (`core/auth.py:229-251, 342-347`). | — |
| 2-9 | 3.2 / D-024 | Access token lifetime 15 min | PASS | `ACCESS_TTL = timedelta(minutes=15)`, `core/auth.py:39`. HS256 is pinned and `exp, iat, jti, sub, typ, dev` are required (`auth.py:177-189`). The 30 s leeway is at `auth.py:45` (B02 P3-3 closed). A `pin_token` is never accepted as a session token (`auth.py:187-188`). | — |
| 2-10 | 3.5.x / D-024 | Per-device refresh rotation and `refresh_reused` revocation | PASS | The refresh token is `<device_id>.<256 random bits>` and only its SHA-256 is stored (`service.py:249-270`). It rotates on every use and the previous hash is kept (`service.py:500-501`). Presenting the rotated-out token signs the device out and answers `refresh_reused` (401) (`service.py:289-312, 735-743`). | — |
| 2-11 | 2.1.x | Password rules | N/A | There are no passwords. The OTP is the authenticator; the 4-digit PIN is a second step for office roles (`identity/schemas.py:79`). | — |

## V3 Session management

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 3-1 | 3.3.1 | Logout invalidates the session | PASS | `logout` → `_sign_out` sets `revoked_at` and clears both refresh hashes (`identity/service.py:699-708, 749-765`). The next request's device read refuses every access token (`core/auth.py:346-347`). Tokens issued before a later sign-in stay dead (`auth.py:216-226`). | — |
| 3-2 | **3.3.2** | **Re-authentication at least every 30 days (L1)** | **FAIL → P1-1** | Refresh tokens never expire by time. D-024.md:53 says so ("the farmer stays signed in for the season") and D-024.md:85 says so again. D-024.md:85 also says a lost phone stays signed in "until someone revokes the device", but the API has no device-revoke route: the OpenAPI holds no `device` or `session` path. The only revocation is rejecting the farmer (`registry/service.py:1629-1673`). | In `refresh` (`service.py:731-746`), sign out and refuse with 401 when `device.signed_in_at < now − 30 d` (ASVS L1; the Architect-Gate may accept a longer farmer limit in D-024), or at least `last_seen_at < now − 30 d`. Add one unit test. P2: an FPO-admin `POST /v1/devices/{id}/revoke` (audited). Owner: new identity hotfix WP (B23) and a D-024 amendment. |
| 3-3 | 3.4.1-3.4.3 | Cookie attributes (portal refresh cookie) | PASS | The `agritrace_refresh` cookie is `httponly=True, secure=True, samesite="strict"`, `path=/v1/auth` (`identity/router.py:78-91`). It is deleted with the same attributes on logout (`router.py:270-271`). A token read from the cookie is only ever answered through the cookie (`router.py:247-251`). | — |
| 3-4 | 3.2.3 | Portal token storage | PASS | The access token lives only in React state (`apps/portal/src/auth/AuthProvider.tsx:64`). localStorage holds only the non-secret device id (`authApi.ts:20-45`). | — |
| 3-5 | 3.2.3 (mobile) | Phone token storage | PASS | Tokens are in `flutter_secure_storage` (Keychain `first_unlock_this_device`, Keystore), not SQLite (`apps/mobile/lib/core/router/session.dart:99-103`, `core/db/daos/session_dao.dart:27`, D-027). Android sets `allowBackup="false"` (`android/app/src/main/AndroidManifest.xml:16`). Sign-out calls the API, then `deleteAll` (`session.dart:148, 322-331`). | — |
| 3-6 | 3.3.1 / P09 | Portal sign-out behaviour | PASS | P09 (WEB/SEC review FAIL r1, then r2 confirmed and merged): sign-out waits for the server (401 → refresh cookie → logout). If that fails it keeps the session and shows "Could not sign out". Tests: `auth/auth.test.tsx:212-237`. | — |
| 3-7 | 3.3.x / P09 | Chrome "continue where you left off" restores the previous user's session cookie on a shared PC | PARTIAL | TODO.md:311. The cookie is a browser-session cookie (D-022), and Chrome's session restore keeps it. Because of 3-2, the server never times it out either. | The P1-1 fix bounds it. In addition, refuse web refreshes idle for more than 12 h (`platform == web` and `last_seen_at`). Owner: P00/B02 (with B23). |
| 3-8 | 3.x | Assist sessions have no maximum age | PARTIAL | `_assist_farmer` checks the session id, the officer and `ended_at IS NULL`, but not the session's age (`core/auth.py:254-276`; B02 P3-5). A forgotten session keeps attributing entries to the farmer. | Add `started_at > now − 12 h` to the header path. Owner: B02 follow-up (product to confirm the 12 h). |

## V4 Access control

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 4-1 | 4.1.1, 4.1.3 | Server-side role checks; deny by default | PASS | `require_role` (`core/auth.py:365-396`) sits on every authenticated route. The OpenAPI scan finds 95 operations; only 11 carry no security requirement, and all 11 are intentional: `otp/request`, `otp/verify`, `refresh`, `GET`/`HEAD /v1/healthz`, `POST /public/scans`, `GET /public/batches/{code}` (404 in prod, `publishing/service.py:410`), and four 501 stubs (`partner_api/router.py:24-58`, `storage_monitoring/router.py:23-55`). | — |
| 4-2 | 4.2.1 | IDOR and FPO tenant scoping (sample of 17 routes) | PASS | Every sampled route filters on the token's `fpo_id`, and another FPO's id answers 404, so ids from other tenants are not confirmed (FR24). See the table below. | — |
| 4-3 | 4.1.x / CLAUDE.md §6 | Assist mode recorded on every entry | PASS | `get_current_user` puts `on_behalf_of_farmer_id` and `assist_session_id` into the audit context (`core/auth.py:348-361`). Event versions store both (`events/models.py:94-97`, written at `events/service.py:477, 532`). An assisted write is limited to that farmer's lots (`events/service.py:300-306`). Ended sessions are accepted only on the sync path (D-032, `auth.py:279-302`). | — |
| 4-4 | 4.2.1 / 8.3.x / D-017 | Farmer phone reveal is admin-only and audited | PASS | `GET /v1/farmers/{id}/phone` uses the `Admin` dependency, sends `Cache-Control: no-store` and writes an audit row (`registry/router.py:394-431`). The service scopes it to the FPO and writes the `farmer.phone_reveal` audit row without the number (`registry/service.py:1605-1626`). Lists show only `phone_masked` (`registry/service.py:1454`, `registry/schemas.py:263`). P10 (WEB/SEC PASS) wired the portal button. | — |
| 4-5 | 4.1.x | Super-admin scope | PASS (documented) | The flag counts only on routes that list it: `list_flags` (`rules_flags/service.py:820-823`), `get_fpo` (`registry/service.py:1794`) and the `SuperAdmin` routes in registry. It fails closed elsewhere (B02 P3-6). The token-claim vs DB-read split is TODO.md:116. | — |
| 4-6 | 4.3.1 | Admin interfaces need authentication | PASS | Every portal admin action is behind `require_role(Role.FPO_ADMIN)` (the `Admin` aliases in the registry, lots_batches, publishing and reporting routers). | — |

### Tenant scoping sample (V4.2.1)

| # | Route | Module | Where the FPO filter is applied |
|---|---|---|---|
| 1 | `GET /v1/farmers` | registry | `Farmer.fpo_id == user.fpo_id`, `registry/service.py:647` |
| 2 | `GET /v1/farmers/{id}` | registry | `_farmer_in_scope` (same FPO, and a farmer sees only themself), `registry/service.py:389-410`, call at :679 |
| 3 | `GET /v1/farmers/{id}/phone` | registry | `_farmer_in_scope`, `registry/service.py:1623` |
| 4 | `GET /v1/plots/{id}` | registry | `_plot_in_scope`, `registry/service.py:413-431`, call at :1076 |
| 5 | `GET /v1/lots` | lots_batches | `Lot.fpo_id == user.fpo_id`, `lots_batches/service.py:585` |
| 6 | `GET /v1/batches/{id}` | lots_batches | `_batch_in_scope`, `lots_batches/service.py:360-375`, call at :1074 |
| 7 | `POST /v1/batches/{id}/publish` | lots_batches | `_batch_in_scope`, `lots_batches/service.py:1246` |
| 8 | `GET` quality readings | quality | `_load_lot` / `_load_batch` check `fpo_id`, `quality/service.py:502, 529`, used at :854-888 |
| 9 | `GET /v1/flags` | rules_flags | `assert_same_fpo` unless super-admin, then `Flag.fpo_id == fpo`, `rules_flags/service.py:820-823` |
| 10 | `GET /v1/dashboard/fpo/{fpo_id}` and `/farmers` | reporting | `assert_same_fpo(user, fpo_id)`, `reporting/router.py:94, 146` |
| 11 | audit rows and audit CSV | reporting | `user.fpo_id` passed in, `reporting/router.py:214, 248`; batch check `reporting/service.py:817` |
| 12 | publishing builds and labels | publishing | `_batch_in_scope`, `publishing/service.py:106-124`, calls at :210 and :375 |
| 13 | `GET /v1/farmers/{id}/consents` | identity | `_farmer_in_fpo` → `assert_same_fpo`, `identity/service.py:799-817`, call at :1022 |
| 14 | `GET /v1/sync/changes` (pull) | events | `fpo = user.fpo_id` on every table, and a farmer's own rows only, `events/pull_service.py:245-277` |
| 15 | `POST /v1/sync/photos/confirm` | events | key prefix `evidence/{user.fpo_id}/`, and only the uploading user may confirm, `events/service.py:1073-1110` |
| 16 | `GET /v1/notifications` | notifications | `Notification.user_id == user_id`, `notifications/service.py:92-110` |
| 17 | `GET /v1/lots/{id}/events` | events | `lot.fpo_id != user.fpo_id` → 404, `events/service.py:1213` |

All 17 pass.

## V5 Validation, sanitisation and encoding

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 5-1 | 5.1.3, 5.1.4 | Pydantic validation at the boundary | PASS | Every body and parameter is a Pydantic v2 model. The public record has `extra="forbid"` (`apps/public-page/agritrace_page/schema.py:29-36`), and so does the field config (`core/fieldconfig.py:49`). Phone and OTP fields are pattern-checked (`identity/schemas.py:25, 31-32`). | — |
| 5-2 | 5.1.x / B21 | NUL characters and int32 maxima | PASS | `NoNulStr`, `has_nul` and `INT32_MAX` (`core/schemas.py:20-63`) turn values Postgres refuses into 422s instead of 500s. B21 (BE/SEC PASS) applied them per sync entry. | — |
| 5-3 | 5.1.x / 12.1.1 / B18 | Content-Length bound on photo uploads | PASS | `MAX_PHOTO_BYTES = 2 MiB` with `size_bytes` declared (`events/schemas.py:41, 53`). The length is signed into the PUT (`core/storage.py:85, 103-104`, `events/evidence.py:76-99`). Verify reads at most size + 1 bytes (`evidence.py:211-227`). B18 SEC review: PASS. | — |
| 5-4 | 5.1.x / 12.1.1 | CSV import limits | PASS | 2 MB and 5,000 rows, UTF-8 only, extra cells refused (`registry/imports.py:43-44, 94-115`). The upload spools to disk before the size check (Starlette `UploadFile`). | — |
| 5-5 | 5.1.x / 13.1.x | Sync push size limits | PARTIAL | 256 KiB per body and `MAX_ENTRIES` (`events/sync_router.py:37, 66-70`, `events/schemas.py:318`). A chunked body without Content-Length is read in full before it is measured (`shortcut:` at `sync_router.py:64-65`), and no other route has a body cap. | Cap request size at the ALB/CloudFront (deploy checklist) or in a small ASGI guard. Owner: infra (B21 deploy notes). |
| 5-6 | 5.3.x | Output encoding: HTML, CSV | PASS | The Jinja environment has `autoescape=True` (`agritrace_page/render.py:232`). CSV formula injection is neutralised in the server export (`reporting/service.py:198-205`) and in the portal export (D-051). | — |
| 5-7 | 5.3.4 | SQL injection | PASS | SQLAlchemy Core/ORM throughout. Raw SQL is parameterised (e.g. `registry/service.py:1440` with `CAST(:fpo_id AS uuid)`). | — |

## V7 Error handling and logging

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 7-1 | 7.4.1 | Generic error envelope; no stack traces or DB text to clients | PASS | Every error derives from `AppError` and goes through `install_handlers` (`core/errors.py:639-652`). Validation details keep only `loc, msg, type`, never `input` (`errors.py:568`). A DB error becomes `append_only_violation`, `retry_later` or `internal_error` (`errors.py:597-617`). Unhandled exceptions are logged server-side and the client gets `internal_error` (`errors.py:622-635`). The health probe returns the exception class only (`main.py:80`, infra/README). | — |
| 7-2 | 7.1.1, 7.1.2 | No secrets or PII in logs | PASS | I grepped every `log.*` call in `apps/api/agritrace` (33 sites). They log ids, task names and counts. The console SMS provider logs only the redacted text, never the phone (`notifications/providers.py:50-66`). Celery `args`/`kwargs` are masked (`worker/__init__.py:40-67`), which closes B02 P3-11. Settings hide input in errors (`core/config.py:25`). `events/service.py:270` logs task kwargs, and its only callers pass ids (`:627, :1123`). | — |
| 7-3 | 7.x / FR25 | Audit log append-only; secrets redacted | PASS | A trigger refuses UPDATE/DELETE on `audit_log` and `event_versions` (`alembic/versions/0001_initial.py:40-62` (trigger function and `APPEND_ONLY` map)). `*_hash` and `*_secret` columns are written as `[redacted]` (`core/audit.py:105-159`). | — |
| 7-4 | 7.x / TODO.md:97 | The DB role can disable the append-only triggers | PARTIAL | The API's role owns the tables, so it could `ALTER TABLE … DISABLE TRIGGER` (TODO.md:97). | Production: migrations run as an owner role and the API as a non-owner role with DML grants only. Owner: infra review / SEC, at deploy. |
| 7-5 | 7.2.1 (L2) | Security event log | N/A at L1 (open) | OTP failures and locks, PIN locks and refresh reuse produce no log line or audit row (B02 P3-7). | Add structured log lines (no codes or tokens) when observability lands. Owner: B02 follow-up. |

## V8 Data protection and privacy

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 8-1 | 8.1.x / D-008 / D-011 | Evidence bucket write-once | PASS (local) / PARTIAL (prod) | `evidence` is created with object lock, versioning and default GOVERNANCE retention of 1 day in dev (`infra/scripts/s3-init.sh:20-31`). PUTs are bound to sha256 + length + content type (5-3, 12-1). The production retention mode and period are left to the infra review (infra/README "Buckets"). | Infra review: COMPLIANCE mode and a pilot-length retention on AWS. Owner: infra (deploy). |
| 8-2 | 8.1.x / 6.1.1 | `id-docs` bucket: private, encrypted, flag-gated | PARTIAL | Private, with the public access block on (`s3-init.sh:40`). Off by default: `id_document_capture: false` (`apps/api/config/features.yaml:8`), enforced by `_feature` → 404 (`registry/router.py:74-101`). Captures require an active consent (`registry/service.py:1395-1396`). **No explicit server-side encryption is configured**, and the upload has no confirm step (TODO.md:171, 230). | Add `put-bucket-encryption` (SSE-KMS) in s3-init and the AWS bucket. Owner: infra / B13, before the flag is turned on. |
| 8-3 | 8.3.1 | Sensitive data not in URLs | PASS | Phones and OTPs travel only in bodies. Refresh tokens travel in the body or a cookie, never a query string. | — |
| 8-4 | **8.3.2** | **Users can have their data removed or exported** | **FAIL → P1-2** | No erasure or export path or runbook exists. The append-only tables (events, audit) conflict with DPDP Act 2023 deletion requests (TODO.md:97, "Owner: SEC review before G5"). Consent revocation exists (`POST /v1/consents/{id}/revoke`), but it does not erase anything. | Docs-only for the pilot: write an erasure and export runbook (manual, DBA-run). Cover: which tables can be redacted vs which must be kept as a legal record; redacting phone, plot pin and survey number in `audit_log` diffs; deleting `id-docs` objects; the response deadline. Link it from D-017. Owner: Architect-Gate + SEC (docs), before pilot go-live. |
| 8-5 | 8.3.4 / CLAUDE.md §6 | No phone, ID, survey number or boundary on public pages | PASS | Three layers. (1) The allow-list schema with `extra="forbid"` plus value checks for phone, Aadhaar, survey/patta and polygon (`agritrace_page/schema.py:29-56`). (2) The pin rounded to 3 dp in the schema and in the builder (`schema.py:173-197`, `publishing/builder.py:493`). (3) The privacy linter runs on the built page before anything is written to S3 (`publishing/service.py:325-341`, `builder.py:626-641`, `agritrace_page/privacy_lint.py:45-135`). | — |
| 8-6 | 8.3.4 | Privacy linter gap: `S. No. 45` | PARTIAL | `S. No.` / `S.No.` (a Tamil Nadu survey-number form) is not flagged. It also means "serial number", so flagging it risks false positives (TODO.md:329, B18-r1 P3-1). The schema blocks survey fields structurally, so only free text could carry one. | Product/privacy to decide the contexts. Then add the rule plus a LEAKS row and a look-alike row in `qa/tests/test_privacy_lint.py`. Owner: W03 / B18 follow-up. |
| 8-7 | 8.3.4 | Partner payloads | PASS (no payload yet) | Both partner routes are stubs that raise `NotImplementedPilotError` (501) and return no data (`partner_api/router.py:24-58`). When they are built, the partner payload must go through `privacy_lint.scan_text` as the page does (the linter's docstring already lists partner payloads). | — |
| 8-8 | 8.2.x | Shared office browsers keep no copy of revealed phones | PASS | `Cache-Control: no-store` on the reveal (`registry/router.py:429`). The portal keeps the number only until the page is left (P10). | — |

## V9 Communications

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 9-1 | 9.1.1-9.1.3 | TLS for all client traffic | N/A locally (prod infra) | TLS terminates at the ALB/CloudFront (infra/README "Production notes"). The local stack is plain HTTP by design. Mobile prod builds take an `https://` `API_BASE_URL` (apps/mobile/README). The refresh cookie is `Secure` (3-3). | Deploy checklist: HTTPS only, HTTP → HTTPS redirect, TLS 1.2+. Owner: infra. |

## V12 Files and resources

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 12-1 | 12.1.1, 12.5.x | Presigned PUT bound to checksum, length and content type | PASS (evidence) | `presign_put` signs `ContentType`, `ChecksumSHA256` and (since B18) `ContentLength` (`core/storage.py:65-108`). The URL lives 15 min (`events/evidence.py:39`). M16 judges URL expiry on the server clock. | — |
| 12-2 | 12.1.1 | ID-document presign has no length | PARTIAL | `storage.presign_put(key, content_type, sha256, ID_DOC_URL_TTL_S, bucket=…iddocs)` is called without `size_bytes` (`registry/service.py:1413-1415`; TODO.md:330, B18-r1 P3-2). The feature is off by default. | Add `size_bytes: int = Field(gt=0, le=MAX)` to `IdDocumentIn` and pass `size_bytes=`. Owner: B13 follow-up, before `id_document_capture` is turned on. |
| 12-3 | 12.x / PLAN §13 B2 | EXIF stripped on the phone | PASS | The phone rewrites EXIF to DateTimeOriginal, GPS and orientation only, dropping maker notes and thumbnails (`apps/mobile/lib/core/capture/exif_rewriter.dart:1-15`). The server reads EXIF only to verify (`events/evidence.py:121-184`). | — |
| 12-4 | 12.x | WebP variants for public use | PASS | `webp_variant` re-encodes the image, so only pixels survive, under a byte budget (`events/evidence.py:186-209`). Public pages use those variants, and signed variant URLs are short-lived (`evidence.py:235, 268`). | — |
| 12-5 | 12.4.1 | Uploads stored outside the web root, not executable | PASS | All uploads go to S3 buckets, never the API's filesystem. Content types are enumerated (`Literal["image/jpeg", "image/webp"]`, `registry/schemas.py:582`). | — |

## V13 API and web services

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 13-1 | 13.2.x / 11.1.4 | Rate limits on OTP and scans | PARTIAL | OTP: per phone only (2-4). Scans: 100/min, and 10/min for unknown codes, per client IP in Valkey (`reporting/service.py:83-85, 236-262, 864-899`). The IP comes from `request.client.host` (`reporting/router.py:295`), but uvicorn runs without `--forwarded-allow-ips` (`apps/api/Dockerfile:34`). Behind the ALB, every consumer would then share the ALB's address and one 100/min budget. | Set `FORWARDED_ALLOW_IPS=*` in the api task definition (only the ALB reaches the task) and record it in the B21 deploy notes. Owner: infra / B21. |
| 13-2 | 13.1.x / 14.5.3 | CORS | PASS | No `CORSMiddleware` anywhere in `apps/api`. The portal shares the API origin (D-022), so browsers apply same-origin. The public scan beacon is a simple request. | — |
| 13-3 | 13.2.x / D-005 | Idempotent push | PASS | Every entry carries a phone-generated `client_id` (UUIDv7, `events/schemas.py:49, 229, 238`). A replay returns the stored version (`events/service.py:316, 408-409`), and an id owned by another user or FPO is `client_id_conflict` (`events/service.py:166-169, 414, 455`). Writes use `INSERT … ON CONFLICT DO NOTHING` (`events/service.py:121`). | — |
| 13-4 | 13.x | Background job durability (OTP SMS) | PARTIAL | Celery has no `visibility_timeout`. A worker stopped mid-task strands the message for the 3600 s default, so an OTP SMS could arrive after its code expired (TODO.md:399). The OTP task is also enqueued without `expires=` (`identity/service.py:399`; B04 P3). | `app.conf.update(broker_transport_options={"visibility_timeout": 300})` in `worker/__init__.py:33`, and `expires=OTP_TTL` on the OTP `send_task`. Owner: B04/B02 follow-up. |
| 13-5 | 13.x | Timing oracle on `otp/request` | PARTIAL | Only known phones pay the broker round trip (`identity/service.py:440-441`; B02 P3-2). | Enqueue after the response (`BackgroundTasks`), or do a no-op for unknown phones. Owner: B02 follow-up. |

## V14 Configuration

| # | ASVS | Item | Result | Evidence | Fix / owner |
|---|---|---|---|---|---|
| 14-1 | 14.1.x / 2.10.4 | Secrets via the environment, none in code | PASS | `jwt_secret: str = Field(...)` has no default, so the API does not start without it (`core/config.py:53`, checked at boot by `main.py:149-167`). Compose sets dev values (`infra/docker-compose.yml:13, 25-26`). | — |
| 14-2 | 14.1.x | `.env.example` documents every variable | PASS | `apps/api/.env.example` covers every `Settings` field with its prod rule. | — |
| 14-3 | 14.1.x / D-017 | YAML schema check at startup | PASS | The lifespan runs `get_settings()` and `fieldconfig.check_page_required(fieldconfig.load(), …)`, so a bad file stops uvicorn (`main.py:149-167`). The schemas use `extra="forbid"` (`fieldconfig.py:49, 206-240`). | — |
| 14-4 | 14.1.x | The prod guard depends on `ENV=prod` | PARTIAL | `ENV` defaults to `dev` (`config.py:27`; B02 P3-9), so a deployment that forgets `ENV=prod` runs with every dev allowance. | Assert `ENV=prod` in the ECS task definition, or make `env` required. Owner: infra / B00. |
| 14-5 | 14.4.x | Security headers (CSP, nosniff, HSTS, frame-ancestors, Referrer-Policy) | PARTIAL (deploy) | Neither the API, the portal `index.html` nor the public page sets any of them (I grepped the apps; `curl -I /v1/healthz` returns only date, server and content-length). | A CloudFront response-headers policy for the portal and public pages (HSTS, `frame-ancestors 'none'` for the portal, nosniff, Referrer-Policy) plus `X-Content-Type-Options: nosniff` on API responses. Owner: infra (deploy) / B00. |
| 14-6 | 14.3.x | Swagger UI and `/openapi.json` served in prod | PARTIAL (advisory) | `create_app` keeps FastAPI's default `/docs` and `/openapi.json` in every environment (`main.py:183-189`). The spec is in the repo, so little is disclosed. | Optional: `docs_url=None` when `ENV=prod`. Owner: B00. |
| 14-7 | 14.2.x | Dependency ledger and licences | PASS | `docs/LIBRARIES.md` is checked by `infra/scripts/libraries-check.py` in CI. TODO.md:130 notes 16 npm-audit advisories in dev-only `@lhci/cli` (not shipped). | — |

## Known open items (folded in, not rediscovered)

| Item | Where | Result here |
|---|---|---|
| DPDP erasure, retention, DB role ownership | TODO.md:97 | 8-4 **FAIL (P1-2)**, 7-4 PARTIAL |
| 13 B02 P3s | TODO.md:120, B02-r1.md:271-312 | P3-1 closed (`service.py:147`). P3-2 open (13-5). P3-3 closed (`auth.py:45`). P3-4 mostly closed: a replayed `pin_token` still needs the PIN, and `signed_in_at` kills it after a sign-in. P3-5 open (3-8). P3-6 documented (4-5). P3-7 open, L2 (7-5). P3-8 → **3-2 FAIL (P1-1)**. P3-9 open (14-4). P3-10 closed (D-024 comments at `auth.py:342`). P3-11 closed (`worker/__init__.py:40-67`). P3-12 closed (`\f` in route docstrings). P3-13 optional (2-6). |
| B02-r2 P3s | TODO.md:132 | Whole-second `signed_in_at` (`auth.py:216-226`, P3 accepted); OTP daily cap lets an attacker lock out a victim (2-4) |
| Celery `visibility_timeout` | TODO.md:399 | 13-4 PARTIAL |
| `S. No.` linter gap | TODO.md:329 | 8-6 PARTIAL |
| ID-document presign without length | TODO.md:330 | 12-2 PARTIAL |
| Chrome "continue where you left off" | TODO.md:311 | 3-7 PARTIAL |

## SEC-hat reviews already done (for the gate to cite)

| WP | Review file | Hat | Verdict |
|---|---|---|---|
| B18 | `docs/agents/reviews/B18-r1.md` | BE Reviewer, SEC hat | PASS (P1 0, P2 1, P3 3) |
| B19 | `docs/agents/reviews/B19-r1.md` | BE Reviewer (concurrency; the file names no SEC hat) | FAIL r1 (P1 1: lock order, deadlock). The r2 fixes were confirmed by the Orchestrator, then merged (CHANGELOG, `72c52b5`) |
| B20 | `docs/agents/reviews/B20-r1.md` | BE Reviewer | PASS (P1 0, P2 2, P3 3); micro-patch confirmed (`5f17f0e`) |
| B21 | `docs/agents/reviews/B21-r1.md` | BE Reviewer, SEC hat | PASS (P1 0, P2 1, P3 4); micro-patch confirmed (`f795695`) |
| M14 | `docs/agents/reviews/M14-r1.md` | MOB Reviewer, SEC hat | PASS (no P1; fixes 1-3 as a micro-patch) |
| M16 | `docs/agents/reviews/M16-r1.md` | MOB Reviewer, SEC hat | PASS (no P1, no P2, 3 optional P3s); M14 micro-patch confirmed |
| P09 | `docs/agents/reviews/P09-r1.md` | WEB Reviewer, SEC hat | FAIL r1 (P1 1: sign-out cleared the screen while the cookie stayed valid). The r2 fix was confirmed by the Orchestrator, then merged |
| P10 | `docs/agents/reviews/P10-r1.md` | WEB Reviewer, SEC hat | PASS (P1 0, P2 1, P3 3) |

## P1 list for G5

1. **P1-1 (3-2, ASVS 3.3.2).** Refresh tokens need a re-authentication limit.
   - In `identity/service.py` `refresh`, after the `outcome == "ok"` check: when
     `device.signed_in_at is None or device.signed_in_at < utcnow() - REAUTH_AFTER`, call `_sign_out(device)`,
     commit, and raise `UnauthorizedError(details={"reason": "reauth_required"})`.
   - `REAUTH_AFTER = timedelta(days=30)` is the ASVS L1 value. The Architect-Gate may set a longer farmer
     value and record that deviation in D-024.
   - Add one unit test.
   - Amend D-024 "Consequences". Its claim that someone "revokes the device" has no route behind it; either
     add the FPO-admin revoke route (P2) or reword the claim.
   - The phone and the portal already handle a 401 on refresh by signing out.
2. **P1-2 (8-4, ASVS 8.3.2, DPDP).** Write a docs-only erasure and export runbook before pilot go-live (scope
   in 8-4) and link it from D-017 and TODO.md:97.

Neither touches the public-page privacy chain or the sync contract.

PARTIAL count by chapter: V2 2 (2-4, 2-5), V3 2 (3-7, 3-8), V5 1 (5-5), V7 1 (7-4), V8 3 (8-1 prod, 8-2, 8-6), V12 1 (12-2), V13 3 (13-1, 13-4, 13-5), V14 3 (14-4, 14-5, 14-6) = **16 PARTIAL**; 9-1 (TLS) is N/A locally and goes on the deploy checklist with 8-1, 13-1, 14-4 and 14-5.

What I did not do: no live attack on the running stack, no dependency CVE scan, and no check of the AWS
account or CloudFront config (none is in the repo). Risk the user must know: the two P1s are policy gaps,
not exploitable bugs. Most PARTIALs close at deployment (ALB, CloudFront, ECS task definition), so the
deploy checklist must carry them.
