# Ponytail audit: waves 0–2 foundation and contract code (merged tree on `main`, 2026-11-01)

<!-- Purpose: the /ponytail-audit report the G0 and G1 gates require (PLAN.md §3). Serves: CHECKLIST gates G0/G1.
Readers: Orchestrator, Architect-Gate, owners of the WPs named below. Filed by the Architect-Gate. -->

Architect-Gate audit for gates G0 and G1, run with the `ponytail:ponytail-audit` rules on `main` @ `22228f4`. No code
was changed. I ran no full test suites, because other Verifiers were loading the host (load average about 60 to 100).
I ran these read-only checks: `gate-readiness.py G0/G1`, `libraries-check.py`, `gen-error-codes.py --check`, an
OpenAPI drift and validation check, and one Robot run of the G0/G1 tests (9 tests). The backend core was read in full.
The mobile `lib/core`, the portal shell plus the public page, and the `infra` plus `qa` areas were each read by one
read-only sub-auditor. I checked every P1 against the code myself before ranking it. Findings that
`docs/agents/audits/waves-3-6.md` or TODO.md already track are left out.

| Area (scope) | Work packages |
|---|---|
| `apps/api/agritrace/core/**`, `main.py`, `alembic/**`, `modules/*/models.py`, `tests/conftest.py` | B00, B01, B02 (models), B17 (harness) |
| `infra/**`, `qa/**`, root `Makefile` | B00, Q00, W02, B12 |
| `apps/mobile/lib/core/**`, `app.dart`, `bootstrap.dart`, `main_*.dart` (there is no `lib/app/`) | M00, M01, M04, M05, M06; M02/M03 (wave 3) live in `lib/core/sync` and `lib/core/rules` too |
| `apps/portal/src/{api,auth,mocks}/**`, app shell (`main.tsx`, `AppProviders.tsx`, `AppRoutes.tsx`, `queryClient.ts`, `navigation.ts`, `theme.ts`) and the portal config (there is no `src/app/`) | P00; P01 edited `src/auth` |
| `apps/public-page/agritrace_page/**` | W01, W02, W03 |
| `packages/openapi/openapi.json` (spec shape) | B01 and every API WP |

**What this repo does:** AgriTrace traces GI-tagged dry chilli from the farm to the consumer. Farmers and officers log
events on an offline-first Flutter app, which syncs to a FastAPI/PostGIS backend. FPO staff work in a React portal. A
published batch gets a static public page behind a QR code.

**Load assumed:** one pilot FPO with a few hundred farmers. About 10 officer and QC phones run on low-end Android Go
(2 GB RAM), some shared between users (D-029), often offline for days on 2G/3G. Phone clocks may be wrong. Five to ten
staff use the portal on one or two shared office PCs. Consumers open the public pages from QR codes on weak 3G. CI and
gate scripts run on every merge.

**Severity:** P1 = must fix: a bug, security hole, data loss, privacy leak, or something that breaks at the pilot load.
A P1 blocks the gate of its WP. P2 = should fix. P3 = nice to have.

**Gate impact in one line:** the three P1s belong to wave-3 WPs (P01, M02), so they block **G2**, not G0 or G1. The
G0 WPs (B00, Q00) and the G1 WPs (B01, M00, P00, W01) have **no P1**.

## Must fix

1. **[WP-P01] P1: a browser left signed in locks every other staff member out of the portal on that PC**
   (`apps/portal/src/auth/authApi.ts:L39-46`, `L68-74`; server rule `apps/api/agritrace/modules/identity/service.py:L464-468`)
   - **What this is:** the portal stores one device id per browser in localStorage and sends it with every OTP sign-in.
     The API ties that device row to the last user. Another user can sign in on it only after a logout has set
     `revoked_at`.
   - **Problem:** staff A closes the browser on the shared office PC without clicking "Sign out". The httpOnly refresh
     cookie ends with the browser session, but the device row stays bound to A. Staff B then enters a valid OTP and
     gets 409 `device_in_use` ("This device is signed in for another user."). Nothing in the portal clears the stored
     id, so only "clear site data" helps. No portal code handles `device_in_use`, and the MSW verify handler never
     returns 409, so no test can see this.
   - **Fix:** in `verifyOtp`, catch `ApiError` with code `device_in_use`, remove `DEVICE_ID_KEY` from localStorage and
     retry once with a fresh `deviceId()`. A new id signs nobody out, so the B02 rule still holds. The 409 is raised
     before the commit, so the OTP is not used up. Add one test where the mock answers 409 to the first verify.
   - **If we skip it:** shared office PCs lock staff out on the first day of the pilot.

2. **[WP-M02] P1: photos never upload while the phone clock runs 14 minutes or more fast**
   (`apps/mobile/lib/core/sync/photo_uploader.dart:L38-52`)
   - **What this is:** before each PUT, `usable()` checks that the presigned URL's `expires_at` is later than the phone
     clock plus 1 minute. `expires_at` is in server time, 15 minutes after the URL was issued (`events/schemas.py:318`).
   - **Problem:** suppose a phone clock runs 20 minutes fast, which the three-clocks design expects to happen. Every URL
     then looks stale on arrival. `refreshUploadUrls` re-pushes the entries for fresh URLs, which look stale too, so
     `ready` is always empty and no PUT ever runs. Nothing is shown as an error, and nothing turns `needs_attention`.
     The evidence photos stay on the phone. `_recordSkew` (`outbox_processor.dart:L304-308`) already stores
     `clock_skew_ms`, but no code reads it.
   - **Fix:** in `uploadPhotos`, read `clock_skew_ms` and compare against `c.now().subtract(skew)` (about 3 lines). Add
     one test with the harness server clock 20 minutes behind the phone.
   - **If we skip it:** on any phone with a fast clock, evidence photos never reach S3, silently, and batches built from
     those lots lack their evidence.

3. **[WP-M02] P1: a sync run that started for user A keeps pushing A's entries with user B's token after B signs in**
   (`apps/mobile/lib/core/sync/sync_service.dart:L196-227`, `outbox_processor.dart:L42-47`, `api_client.dart:L133-134`)
   - **What this is:** D-029 says a shared phone never sends one person's entries with another person's token. `_run`
     reads the session's `userId` once. The push loop keeps calling `nextBatch(ownerUserId: c.userId)`, and the auth
     interceptor attaches whatever access token is current at request time. Signing out does not stop a running sync.
   - **Problem:** officer A comes back into coverage with about 150 entries, which is several batches on 2G. A signs
     out, and officer B signs in by OTP a minute later. The remaining batches of A's entries go out with B's token. The
     server takes `entered_by` from the token, so A's readings and intakes are stored as B's. These rows are
     append-only and cannot be repaired. On a family phone, farmer A's events fail the lot-owner check and are rejected
     for good. An in-flight request of A's that gets a 401 is also retried with B's token (`current != sent`).
   - **Fix:** at the top of each `pushEntries` iteration, and before `refreshUploadUrls` and `_confirm`, add
     `if ((await c.db.sessionDao.read())?.userId != c.userId) return;`. The `_again` loop then starts a clean run for
     B. Add one test where the fake push handler switches the session to B, and assert that the second batch is never
     sent.
   - **If we skip it:** on shared phones, entries are credited to the wrong person or rejected for good, and there is
     no way to repair them.

## Should fix

4. **[WP-P01] P2: "Sign out" can fail silently and leave the session alive** (`apps/portal/src/auth/AuthProvider.tsx:L76-81`; mock `apps/portal/src/mocks/handlers.ts:L703-706`)
   - **What this is:** `signOut` runs `logout(token).catch(() => undefined)`, then clears local state.
   - **Problem:** `POST /v1/auth/logout` needs a valid access token. If the Wi-Fi is down or the token has expired, the
     logout fails, but the UI still shows the user as signed out. The refresh cookie and the device binding survive. B
     reloads the page, and the mount refresh signs B in as A, with A's role. The mock logout returns 204 without
     checking `Authorization`, so the only sign-out test cannot fail this way.
   - **Fix:** on a 401 from logout, call `refreshSession().then((s) => logout(s.access_token))`. On a network error,
     keep the session and show "Could not sign out — check the connection". Make the mock logout return 401 unless
     the request is authorised.
   - **If we skip it:** on a shared PC, the next person can be working as the previous one. Fix this together with 1.

5. **[WP-P01] P2: any 5xx or 429 on a token refresh signs the user out** (`apps/portal/src/auth/AuthProvider.tsx:L88-94`)
   - **What this is:** `endIfRejected` should end the session only when the server refused the refresh.
   - **Problem:** the test is `error instanceof ApiError`, and every non-2xx response is an `ApiError`, including a 502
     from a proxy during a deploy. A blip at the moment of the refresh (every 840 s) sends the user to /login, loses a
     half-filled form, and costs an SMS OTP out of the daily cap of 10.
   - **Fix:** `if (error instanceof ApiError && error.status === 401) signOut(); else recoveringFor.current = null;`,
     plus one test where the refresh returns 503 and the session stays.
   - **If we skip it:** users are signed out at random during every API restart.

6. **[WP-W01] P2: the page-schema privacy check misses a phone or Aadhaar number after a word that ends in a digit**
   (`apps/public-page/agritrace_page/schema.py:L104-107`)
   - **What this is:** the number patterns run only on `compact`, a copy of the value with spaces and dashes removed.
   - **Problem:** removing the space joins the earlier digits onto the number, which defeats the `(?<!\d)` lookbehind.
     The sub-auditor's probes return no hit for `"K2 9876543210"`, `"Ward 12 98765 43210"` and
     `"Plot 7 2345 6789 0123"`. `"K2, 9876543210"` is caught. `seed_variety` and the typed village name come from user
     input. This is a new case, not part of the pattern gaps in waves-3-6 finding 3.
   - **Fix:** test both forms:
     `pattern.search(value) or (kind in _NUMBER_PATTERNS and pattern.search(compact))`. Add one test row for
     `"K2 9876543210"`.
   - **If we skip it:** a farmer-typed phone number can reach a public QR page (CLAUDE.md §6).

7. **[WP-B00] P2: production settings accept local defaults for S3 and the public URL** (`apps/api/agritrace/core/config.py:L33-L50`, `L86-L100`; `core/storage.py:L31-L36`)
   - **What this is:** `_refuse_dev_secrets_in_prod` refuses dev JWT, OTP and SMS settings. It does not check
     `PUBLIC_BASE_URL`, `S3_PUBLIC_ENDPOINT` or the S3 keys, which default to `localhost` and `test`/`test`.
   - **Problem:** the `ENV=prod` deploy is missing `PUBLIC_BASE_URL`, so QR codes and labels print
     `http://localhost:4566/public-pages/...` onto packs, and printed packs cannot be fixed. Also, `_client_for` always
     passes the `test` keys to boto3. That blocks the default credential chain, so an ECS or EC2 IAM role is never used,
     and every S3 call fails with `InvalidAccessKeyId`.
   - **Fix:** make `s3_access_key` and `s3_secret_key` `str | None = None`; boto3 then falls back to the role, and compose
     keeps setting `test`. In the prod validator, also refuse `localhost` in `public_base_url` and
     `s3_public_endpoint`. About 4 lines, plus one row in the existing settings test.
   - **If we skip it:** the first production publish can print dead QR links, or S3 fails until someone sets static
     keys by hand.

8. **[WP-B00] P2: compose hard-codes `localhost` for presigned upload URLs and the public base URL** (`infra/docker-compose.yml:17,23`; `infra/README.md:56-58`)
   - **What this is:** the URLs the API gives to phones (photo PUTs) and prints into QR codes.
   - **Problem:** the dev app reaches the API at `10.0.2.2:8000` (`apps/mobile/lib/bootstrap.dart:49`). But upload URLs
     are signed for `http://localhost:4566`, which on an emulator or a LAN phone is the device itself, so photo uploads
     fail. README:57 says to set the LAN IP, but the compose value is a literal that an env var cannot override.
   - **Fix:** `S3_PUBLIC_ENDPOINT: ${S3_PUBLIC_ENDPOINT:-http://localhost:${S3_PORT:-4566}}`, and the same for
     `PUBLIC_BASE_URL`. Add one README line saying the emulator uses `http://10.0.2.2:4566`.
   - **If we skip it:** the G3 photo and offline-sync checks (BM-02, BM-11..14) cannot pass on the compose stack
     unless someone edits the file by hand.

9. **[WP-Q00] P2: the benchmark sweep passes with zero results** (`infra/scripts/benchmarks/collect.py:L84-91,L130-132`; `infra/scripts/benchmarks/README.md:46`)
   - **What this is:** the G5 command that judges BM-01..BM-16 against `thresholds.yaml`.
   - **Problem:** the documented sweep runs without `--require`, so a benchmark with no result counts as MISSING, not
     FAIL. Run against an empty results folder, it lists all 16 as MISSING, prints `collect: PASS` and exits 0.
   - **Fix:** accept `--require all` (`required = set(thresholds) if "all" in args.require else set(args.require)`) and
     use it in README:46. Add one assert to the existing collect test.
   - **If we skip it:** G5 can be signed on an empty benchmark folder.

10. **[WP-W02] P2: the Lighthouse Robot tests skip instead of failing when Chrome or the npm tools are missing** (`qa/robot/public/page.robot:L171-176`, used at `L121-137`)
    - **What this is:** the BM-03 and BM-16 tests, which are the G4 "Lighthouse ≥ 90 on 3G" evidence.
    - **Problem:** `Skip If ${health.rc} != 0` marks both tests SKIP on a machine without Chrome or without `npm ci`. The
      run still reports PASS, and `gate-readiness.py` counts them as real tests.
    - **Fix:** replace it with `Should Be Equal As Integers ${health.rc} 0 msg=...`. A machine without Chrome then has
      to pass `--exclude needs-chrome`, and the report's command line shows that.
    - **If we skip it:** G4 can be signed on two skipped performance tests.

11. **[WP-Q00] P2: libraries-check reads a fixed list of manifests and silently skips any new one** (`infra/scripts/libraries-check.py:L23-30,L193-197`)
    - **What this is:** the check, run at every gate, that `docs/LIBRARIES.md` matches the manifests (D-018).
    - **Problem:** `apps/mobile/packages/agritrace_api/pubspec.yaml` (the generated client, tracked since M00) is not in
      the list. Its `built_value_generator` and `test` have no matching ledger row, yet the script prints PASS. The
      ledger cell `build_runner, built_value_generator (dev, generated package)` also parses into the junk keys
      `built-value-generator (dev` and `generated package)`. The licence risk is nil today, because both are BSD.
    - **Fix:** build the manifest list from
      `git ls-files '*pyproject.toml' '*package.json' '*pubspec.yaml' '*requirements*.txt'`. Move the note out of the
      Library cell and add a `test` row.
    - **If we skip it:** a new manifest escapes the licence gate while the check reports PASS.

12. **[WP-M01] [WP-M02] P2: entries saved while the phone clock was ahead stall after the clock is corrected** (`apps/mobile/lib/core/db/daos/entries_dao.dart:L154-163`, `outbox_dao.dart:L46`, `L101-112`)
    - **What this is:** `_queue` sets `nextAttemptAt` to `createdAt`, taken from the phone clock. `nextBatch` sends only
      rows with `nextAttemptAt <= now`.
    - **Problem:** the phone date is a day ahead, the farmer logs offline, and then the clock is corrected. Those rows
      are due tomorrow, and nothing resets `waiting` rows. `oldestPending` returns a future time, so the 7-day "unsent"
      warning never fires. With the planned fix for waves-3-6 finding 1 (stop at the first row not yet due), one such
      row would stall that user's whole queue.
    - **Fix:** in `resetStaleSending`, which runs at the start of every run, also set `nextAttemptAt = now` on `waiting`
      rows whose `nextAttemptAt > now + maxBackoff`. Add one DAO test with a row due tomorrow. Land it together with
      waves-3-6 finding 1.
    - **If we skip it:** after a clock correction, entries sit unsent with no warning.

13. **[WP-M02] P2: a photo whose confirm call failed is uploaded again in full on the next run** (`apps/mobile/lib/core/db/daos/outbox_dao.dart:L106-112`, `photo_uploader.dart:L96`)
    - **What this is:** after a PUT succeeds, the media row is `sent` until `/sync/photos/confirm` settles it.
      `resetStaleSending` puts `sent` rows older than 5 minutes back to `waiting`.
    - **Problem:** on 2G, the PUT succeeds and the confirm times out. The next run resets the row and PUTs the whole
      ~350 KB again, after a re-push for a fresh URL, before it confirms. `awaitingConfirm` already retries `sent` rows
      on every run, so this reset adds no safety.
    - **Fix:** reset only `OutboxStatus.sending` (delete `sent` from L109). Delete its test
      (`test/db/outbox_dao_test.dart:107-118`) and `EntriesDao.markSent`, which has no caller in `lib/`.
    - **If we skip it:** wasted data and minutes on the worst links, once for every dropped confirm.

14. **[WP-M05] P2: the "Call officer" button is dead in production** (`apps/mobile/lib/core/widgets/call_officer_button.dart:L14-18`)
    - **What this is:** `fieldOfficerPhoneProvider` is hard-coded to `null`, with the shortcut comment "until M06/M07
      override it". Only test harnesses override it, and no officer phone exists in the API, `SessionOut` or any bundle.
    - **Problem:** on every `ConfirmScaffold` screen and on the not-found screen, the button shows but is disabled. The
      UserFlows rule "Help is a person" fails for every pilot farmer. The pilot is past the shortcut's stated limit, and
      TODO.md does not track it.
    - **Fix:** carry the officer's contact in a part the phone already pulls (a B02 or B07 contract change), and
      override the provider in `bootstrap`. Until then, file it in TODO.md.
    - **If we skip it:** a stuck farmer taps a button that does nothing.

## Nice to have

15. **[WP-W02] P3: `check_output.sh` ignores a failed canary load** (`apps/public-page/tools/check_output.sh:L25-28`)
    - **What this is:** the wrapper that adds the canary strings to privacy-lint.
    - **Problem:** the `python -c` sits inside a process substitution, which `set -e` does not cover. With a renamed key
      in `canaries.json`, bash ≥ 4.4 (Ubuntu CI) runs the lint with no canaries and exits 0.
    - **Fix:** use a plain assignment (`values="$("$python" -c ...)"`), which fails under `set -e`, then loop over it.
    - **If we skip it:** a broken canaries file silently turns off the lone-pin defence. `test_render.py` would
      probably still catch the KeyError.

16. **[WP-W02] P3: privacy-lint misses a precise lat/lng pair split across HTML tags** (`infra/scripts/privacy-lint.py:L58,L117`)
    - **What this is:** the coordinate-pair rule. Its separator allows only commas, spaces, `+` and their URL forms.
    - **Problem:** `<td>9.5598061</td><td>78.1335214</td>` and `<span>9.559806</span>, <span>78.133521</span>` both pass
      the lint.
    - **Fix:** add `|(?:\s*<[^>]+>\s*[,;]?\s*)+` to `SEP`, plus one case in `qa/tests/test_privacy_lint.py`.
    - **If we skip it:** only the renderer's coarsening and the fixture canaries guard this shape.

17. **[WP-M06] P3: signing out resets "Photos on Wi-Fi only", and the language after a restart** (`apps/mobile/lib/core/router/session.dart:L337-344`, `db/tables/session.dart:L39`)
    - **What this is:** device settings live in the Session row, and `_endLocally` deletes that row.
    - **Problem:** after any sign-out and sign-in (including the forced `refresh_reused` sign-out), Wi-Fi-only is off
      again, and photos go out over paid mobile data.
    - **Fix:** store `wifi_only_photos` and `locale` as SyncState keys, because they belong to the device, not the user.
    - **If we skip it:** farmers pay for data they asked not to use.

18. **[WP-B01] [WP-B02] [WP-B08] P3: spec shape — 18 component schemas and 4 path parameters have no description** (`packages/openapi/openapi.json`)
    - **What this is:** G1 asks for every schema field to be described. All 1049 properties of the 203 schemas have a
      description. The misses are at the schema level and on parameters.
    - **Problem:** the 15 `Page_*_` schemas (pydantic generic instances of `core/schemas.py` `Page`) and the 3 FastAPI
      multipart `Body_import_*` wrappers have no `description`. The path parameters `consent_id` and `farmer_id`
      (consents, B02) and `flag_id` (flags, B08) are undocumented. The generated clients show these with empty docs.
    - **Fix:** give `Page` `model_config = ConfigDict(json_schema_extra={"description": "One page of a
      cursor-paginated list."})`, and annotate the 4 parameters with `Path(description=...)`. Then run `make openapi` and
      `make clients`.
    - **If we skip it:** small doc gaps in the clients. Not a G1 blocker, because every field is described.

19. **[WP-P00] P3: the placeholder-route loop is dead code** (`apps/portal/src/AppRoutes.tsx:L57-65`, `navigation.ts:L14-15`, `pages/PlaceholderPage.tsx`)
    - **What this is:** the loop maps the `NAV_ITEMS` whose `wp` is not in the merged list to `PlaceholderPage`.
    - **Problem:** every `NAV_ITEMS` entry is in that list, so the loop makes no routes. `PlaceholderPage` and
      `NavItem.wp` have no other users in `src/` or `e2e/`.
    - **Fix:** delete the loop, `PlaceholderPage.tsx`, and the `wp` field and its values.
    - **If we skip it:** every new screen means editing a hard-coded WP list for nothing.

20. **[WP-M00] P3: the `ApiClient.healthz` wrapper is used only by tests** (`apps/mobile/lib/core/api/api_client.dart:L70-79`)
    - **What this is:** a renaming wrapper around the generated `healthzV1HealthzGet`. The sync probe uses its own
      `HEAD` (`connectivity.dart:39`).
    - **Problem:** it has no caller in `lib/`, yet it must stay in step with the generated client.
    - **Fix:** delete it, and have its three tests call `api.getHealthApi().healthzV1HealthzGet()`.
    - **If we skip it:** dead code to maintain.

Left out: 19 smaller items. That covers 6 portal items (for example, the phone field rejects a pasted
"+91 98765 43210", and `indian_number(-0.004)` prints "-0"), 7 infra/qa items (for example, the dev API with
`OTP_DEV_CODE` and LocalStack are bound to all interfaces on the LAN, which is documented as dev-only), and 6 mobile
items (for example, `Media.objectKey` is never read).

Checked and clean, not findings: the backend core (`auth.py` token types, device check per request, role and FPO
guards; `audit.py` same-transaction audit rows with secret redaction; `errors.py` envelope and handlers; `db.py`
mixins; `storage.py` checksum-bound presigned PUT; `ids.py` codes with unique-plus-retry callers; `fieldconfig.py`
narrow-only tenant visibility). The `forbid_change()` append-only triggers in migrations 0001 and 0004. `infra/.env`
is git-ignored and holds only `DB_PORT`. db, Valkey and Mosquitto bind to 127.0.0.1. `ENV=prod` refuses dev
JWT/OTP/SMS. The evidence bucket has versioning plus object lock. `gen-error-codes.py` shows no false green.

**Verdict:** the foundation and contract code is healthy for G0 and G1. Fix 1 and 4 together (portal on shared PCs),
and 2 and 3 (M02 sync), before **G2** is signed.

**Lean:** about -64 lines possible (findings 13, 19 and 20), and no dependencies to remove.

**Not checked:**
- No full suites were run, by instruction. The only run was 9 Robot tests (B00 1, Q00 3, W01 5), all PASS.
- `alembic/versions/0002`–`0003` were skimmed, not read line by line. `modules/*/models.py` was checked at class and
  mixin level only.
- Mobile: `rules/grade_calculator.dart` was only skimmed. Not read: `refdata/models/*`, most widgets, `theme/*`,
  iOS behaviour, and the drift isolate sharing after `container.dispose()`.
- Portal: `src/test/*`, `e2e/*` and most of `mocks/handlers.ts` beyond auth, registry and flags.
- Public page: `page.css`, the i18n texts and `district_outline.json`.
- `qa/fixtures` contents, a real `avdmanager` run, and whether LocalStack enforces object lock (that claim comes from
  `s3-init.sh` and the D-008 Verifier note).
- No GitHub Actions run exists: the repo has no remote.
