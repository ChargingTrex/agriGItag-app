# Ponytail audit: waves 3–6 (merged tree on `main`, 2026-11-01)

Reviewer audit of the code merged in waves 3–6, as the role card asks (docs/agents/roles.md, Reviewer: "at the end of
every wave run `/ponytail-audit`"). No code was changed. I read the code; I ran no test suites, because the host was
under heavy load. Every finding below was checked against `TODO.md` §3/§4 and the per-WP reviews in
`docs/agents/reviews/`. Findings those already track are left out. Each finding names its owning work package.

| Wave | Work packages |
|---|---|
| 3 | B06, B13, M02, M03, P01, P03 |
| 4 | B14, B07, B08, M07, P02, P04 |
| 5 | B09, B15, B16, M08, M09, M10, M11, P05, P06, P08 |
| 6 | B10, B11, M12, W03 |

M13 is wave 7 and was only looked at where it touches M02.

**What this repo does:** AgriTrace traces GI-tagged dry chilli from the farm to the consumer. Farmers and officers
log events on an offline-first Flutter app, which syncs to a FastAPI/PostGIS backend. The FPO office works in a React
portal. A published batch gets a static public page behind a QR code.

**Load assumed:** one pilot FPO with a few hundred farmers and lots per season. Tens of officer and QC phones and a
few hundred farmer phones sync on app open, after each entry and every 15 minutes in the background, often on 2G/3G.
Public pages get hundreds of scans a day.

Severity: **P1** = data loss, privacy leak, security hole, or a crash or forced stop on the farmer's three-tap path.
**P2** = a real defect or scale risk. **P3** = lean or structure.

## Must fix

1. **[WP-M02] P1: a retry after a failed push sends entries out of order, and the server rejects the late ones for good**
   (`apps/mobile/lib/core/sync/outbox_processor.dart:292-294`, `apps/mobile/lib/core/db/daos/outbox_dao.dart:41-49`,
   `apps/mobile/lib/core/sync/sync_service.dart:278-286`)
   - **What this is:** The outbox is the phone's queue of entries waiting to go to the server. When a push fails
     (timeout, 5xx, 429), every row in the batch waits a "backoff" time before its retry.
   - **Problem:**
     - Each row draws its own random wait: `final wait = backoff(i.row.attempts + 1, c.random, error);`.
       `nextBatch` then sends only the rows that are due (`outbox.nextAttemptAt.isSmallerOrEqualValue(now)`).
       So the retry sends whichever row drew the shortest wait, alone, ahead of the rows it depends on.
     - The server needs the rows in order, so the early row is rejected. Rejected rows become `needs_attention`
       and are never sent again.
     - Concrete cases:
       - M09 onboarding on 2G: the `farmer`, `consent` and `plot` rows fail together. On retry `consent` goes
         first and gets `not_found` (`identity.record_consent` → `_farmer_in_fpo`), and the farmer's consent is lost.
       - M10: an assisted harvest goes before its `assist_session` row and gets `assist_session_invalid`.
       - M07/M08: the farmer taps Undo while version 1 is in backoff. The undo (version 2, due now) goes alone and
         gets `not_found` (`events/service.py` `_add_version`: "v > 1 of an unknown event"). Version 1 is stored
         later. The server keeps the event live while the phone shows it undone.
     - This also breaks the D-031 compromise ("order across batches relies on … oldest-first outbox"). A server-side
       500 on a lost insert race (TODO §4 B03 "concurrent first inserts of one plot `client_id` surface as 500")
       sends the whole batch into this path.
   - **Fix:** In `nextBatch`, drop the `nextAttemptAt <= now` filter. Walk `waiting` rows in `seq` order and `break`
     at the first one that is not due yet (strict first-in-first-out per owner; `needs_attention` rows are not
     `waiting`, so they never block). In `_failed`, draw one `wait` per batch, not per row. Add one DAO test: three
     rows, the first in backoff → `nextBatch` is empty.
   - **If we skip it:** On flaky networks, consents and plots of new farmers, assisted entries, QC intakes and undos
     are lost on the server without notice. The officer cannot repair them from the phone.

2. **[WP-M02] P1: the background sync rotates the refresh token, the foreground keeps the old one, and the farmer is signed out**
   (`apps/mobile/lib/core/router/session.dart:254-274` `_doRefresh`, `:157` restore;
   `apps/mobile/lib/core/sync/background_scheduler.dart:62-66`; server `apps/api/agritrace/modules/identity/service.py:711-747`)
   - **What this is:** The refresh token renews the 15-minute access token. Each refresh replaces it with a new one,
     and if the old one is ever presented again the server treats it as stolen (D-024).
   - **Problem:**
     - The WorkManager isolate (the background task, which runs separately from the app) runs every 15 minutes. It
       calls `restore()`, sees an expired access token and refreshes, so T1 becomes T2 in the keystore. The
       foreground isolate still holds T1 in memory, because `_doRefresh` uses `final token = _refresh;` and never
       re-reads the keystore.
     - The farmer reopens the app from recents. The push gets a 401, and the interceptor refreshes with T1. The
       server answers `refresh_reused` and calls `_sign_out(device)`, so T2 dies too. The phone runs
       `_endLocally(sessionEnded: true)`.
     - The farmer sees "You were signed out" and cannot log anything until an SMS OTP arrives. That needs signal,
       which a field often does not have. The unsent entries stay, so no data is lost.
     - This is not in TODO. M02-r1 P2-6 covered isolate exclusion for the outbox, not for tokens.
   - **Fix:** At the start of `_doRefresh`, `readAll()` the keystore. If the stored refresh token differs from
     `_refresh`, adopt the stored tokens and expiry. Return the stored access token when it has not expired, without
     a network call. Add one test: two `SessionNotifier`s on one mock storage; B refreshes; A's 401 must not POST T1.
     Two refreshes at the very same moment still race; that needs the cross-isolate lease M02-r1 proposed.
   - **If we skip it:** Forced sign-outs become routine for any phone whose app stays in recents for more than 15
     minutes, and every one of them blocks the three-tap path until an OTP arrives.

3. **[WP-B10] [WP-W03] P2: published pages never go through the privacy linter, and the check that does run misses common Indian formats**
   (`apps/api/agritrace/modules/publishing/service.py:326-350` `build_page`;
   `apps/public-page/agritrace_page/schema.py:47-58` `_NUMBER_PATTERNS`/`_TEXT_PATTERNS`;
   `infra/scripts/privacy-lint.py` runs only on fixtures in CI)
   - **What this is:** `build_page` renders a batch and writes `index.html` and `data.json` to the public bucket. The
     only privacy check on that path is the schema's `_privacy_violation` inside `render()`.
   - **Problem:**
     - TODO §4 (W02 line: "the built-output privacy lint is the second line of defence") assumes the stronger linter
       also guards real pages. It never runs on them.
     - The schema patterns miss formats the linter catches:
       - land records: `R.S. No. 123/4`, `T.S. No. 45`, and the Tamil `புல எண் 123/4` / `சர்வே எண் 45` / `பட்டா எண் 452` (the land-record pattern is English only);
       - coordinates: a space-separated pair `9.559806 78.133521` (the pattern needs a comma);
       - phone numbers: `98765.43210` and `(98765) 43210`.
     - Free text reaches the page through `farmer_name` (with consent), `address.village` when no directory village
       is set (`builder._place`), `seed_variety` and the processor address. An officer typing
       "Kumarapuram R.S. No. 112/3" as the village publishes it.
     - No stored phone, survey-number or boundary column reaches the page: the builder's allow-list holds. That is
       why this is P2, not P1.
   - **Fix:** Make the linter's scan importable next to `agritrace_page`. In `build_page`, scan `page.html` and
     `page.data_json` before `_write`. On a hit, mark the build `failed` with the paths and raise
     `PublicRecordInvalidError`, like the existing `ValidationError` branch. Stopgap if that waits: add `[RT]\.?\s?S\.?`,
     the Tamil labels and the space-separated pair to `_TEXT_PATTERNS`, with one test each.
   - **If we skip it:** One typed land-record number or phone in a free-text field is published on a QR page anyone
     can open (CLAUDE.md §6).

4. **[WP-B06] P2: a signed-in phone can upload a multi-gigabyte "photo" that cannot be deleted and runs the worker out of memory**
   (`apps/api/agritrace/core/storage.py:65-100` `presign_put`; `apps/api/agritrace/modules/events/service.py`
   `confirm_photos`; `apps/api/agritrace/modules/events/evidence.py:206-222` `_read_object`)
   - **What this is:** Each photo gets a presigned PUT URL, a time-limited upload link signed by the server. The
     link binds the content type and the SHA-256 the phone declared, but not the size.
   - **Problem:**
     - `size_bytes` is checked only as a declaration (`le=MAX_PHOTO_BYTES`, 5 MB). Any farmer account can declare
       300 KB and the SHA-256 of a 4 GB file, then PUT the 4 GB file. S3 accepts it because the checksum matches.
     - `confirm_photos` HEADs the object but never compares `ContentLength`. `events.verify_photo` then calls
       `body.read()` on the whole object ("photos are <= a few hundred KB, so it is read whole") and runs out of
       memory.
     - The object sits in the Object-Lock `evidence` bucket and cannot be removed.
   - **Fix:** In `confirm_photos`, treat `meta["ContentLength"] > MAX_PHOTO_BYTES` (or a value that differs from
     `photo.size_bytes`) as not received. Answer `missing`, do not enqueue verify, and raise a flag. Also refuse in
     `_read_object` when `ContentLength` is over the limit. About four lines; add one unit test.
   - **If we skip it:** One malicious or buggy client can stall photo verification for the whole FPO and fill the
     evidence bucket with undeletable objects.

5. **[WP-M11] P2: the QC "Pick lot" fallback is always empty, so a lot whose QR will not scan cannot be received**
   (`apps/mobile/lib/features/qc_intake/scan_screen.dart:39-46`)
   - **What this is:** When the farmer's Sell QR cannot be read (glare, cracked screen), the QC officer picks the lot
     from a list of ready lots on the QC phone.
   - **Problem:**
     - The list filters `l.status.equals('ready_for_sale')`. The server sets that status only through
       `POST /v1/lots/{id}/ready`, which no phone and no portal screen calls. The intake runs the moisture gate
       itself (D-040).
     - The QC phone pulls the FPO's lots with server status `open`/`drying`. The local `ready_for_sale` preview in
       `pull_service.dart` `_apply` exists only on the farmer's phone, which holds the packing entry. So the list is
       always empty, and the officer sees `qcNoReadyLots`.
     - `packed_kg` is null on the server until intake, so filtering on it would also be empty.
   - **Fix:** List lots with status `open`, `drying` or `ready_for_sale` (newest first). The server's `lot_intake`
     re-runs the ready gate and refuses a wet lot with `moisture_gate_failed`. A one-line filter change, plus one
     widget test.
   - **If we skip it:** The only offline fallback at the collection centre does nothing, and farmers are sent away.

6. **[WP-W03] [WP-B10] P2: a real batch blows the 100 KB page budget at about 8 lots, and the publish path never measures it**
   (`apps/public-page/agritrace_page/render.py:28` `BUDGETS`, `measure()`; `apps/api/agritrace/modules/publishing/service.py` `build_page`)
   - **What this is:** Plan §13 E1 / BM-16 set the initial HTML+CSS+JS under 100 KB. `measure()` checks that, but only
     `cli.py check` and `test_size_budgets` call it, and only on the 3-lot fixture.
   - **Problem:** The built fixture page is 48,827 B. The lots section is about 12.8 KB per lot (10 events with photos);
     the rest is about 10.5 KB. So (102,400 − 10,500) / 12,800 ≈ 7 lots. An FPO batch of 20 lots is about 270 KB of
     HTML, and nothing reports it. This is an estimate from the fixture's per-lot history.
   - **Fix:** Call `measure(page.html)` in `build_page`, log it and store it in the build snapshot. Add one render
     test with 20 lots so a breach is visible. How to trim (fold timelines into `data.json`, or collapse events per
     stage) is a product call.
   - **If we skip it:** QR scans on slow 3G load slowly, which is exactly what BM-03 and BM-16 gate, and nobody sees
     it until Lighthouse runs on a real batch.

7. **[WP-P03] [WP-B09] P2: Ready lots and the batch pages read every farmer one request at a time**
   (`apps/portal/src/features/batches/ReadyLotsPage.tsx:72-92` `useFarmerNames`; used at `ReadyLotsPage.tsx:199`,
   `BatchPage.tsx:457`, the P05 exports)
   - **What this is:** The page fetches `GET /v1/farmers/{id}` once per distinct farmer to show names next to lots.
   - **Problem:** The page lists every `received` and `ready_for_sale` lot of the FPO (two lists of up to `PAGE = 200`).
     At harvest peak that is up to 400 parallel reads, repeated on every visit after 30 s (`staleTime`). The
     `shortcut:` comment's limit ("a season's few dozen lots") is already crossed at pilot size. The portal's
     `shortcut:` comments are also missing from TODO §3, the debt ledger.
   - **Fix:** Add `farmer_name` to `LotOut` and `ShareOut`; the server already loads the farmer when it builds them.
     Then delete `useFarmerNames` (about 25 lines) and run `/ponytail-debt` to refresh TODO §3.
   - **If we skip it:** Request storms on the screen used most at harvest, against an API that is also serving sync.

## Should fix

8. **[WP-B09] P3: batch gate endpoints check and then write without locking the batch**
   (`apps/api/agritrace/modules/lots_batches/service.py` `second_signoff`, `approve_grading`, `final_packing`, `publish`)
   - **What this is:** Each gate reads the batch with `_batch_in_scope` (no row lock), checks its status, then writes.
   - **Problem:** Two requests at once (a double click, or two admins) both pass the check.
     - `publish` twice: both set `current_build_no + 1`, and the second hits `UniqueConstraint("batch_id", "build_no")` → 500.
     - `approve_grading` or `final_packing` twice: two approval rows in the append-only table, and the last
       `graded_kg` / `packed_kg` wins silently.
     - Intake and merge already lock their rows (B09-r2 P2-1); these gates do not.
   - **Fix:** Pass `with_for_update=True` in `_batch_in_scope` for these four callers (an optional `lock` argument,
     as `_lot_in_scope` already has). One argument at each of four call sites.
   - **If we skip it:** Occasional 500s and duplicated approval rows that no one can remove.

9. **[WP-P04] P3: the gate preview turns the buttons on when the hold check fails** (`apps/portal/src/features/batches/BatchPage.tsx:466-474`)
   - **What this is:** Approve, Pack and Publish stay grey while hold flags are loading (`checking_holds`).
   - **Problem:** If `GET /v1/flags` or one `GET /v1/lots/{id}` returns 500, `isPending` is false and the holds list is
     `[]`. The buttons enable with no reason, which contradicts the code's own comment ("an empty list does not prove
     the batch is free"). The server's 409 still decides, so this is UI only.
   - **Fix:** Also add `checking_holds` when `holdFlags.isError || lots.some((q) => q.isError)`.
   - **If we skip it:** Admins click buttons that then fail with a 409 they were not warned about.

10. **[WP-P03] [WP-P04] P3: the Batches list stays stale after create, approve or pack**
    (`ReadyLotsPage.tsx:255-257`, `BatchPage.tsx:90, 203, 362`, `BatchesPage.tsx:41`)
    - **What this is:** Mutations update only `['lots']` or `['batches', id]`. The list uses `['batches', 'list', …]`
      with a 30 s `staleTime`.
    - **Problem:** The admin creates a batch, opens Batches within 30 s, and the new batch is missing. An approved
      batch still shows "Created".
    - **Fix:** `queryClient.invalidateQueries({ queryKey: ['batches', 'list'] })` in those `onSuccess` handlers.
    - **If we skip it:** Admins think the action failed and repeat it, which also feeds finding 8.

11. **[WP-M08] [WP-M11] [WP-P06] [WP-P01] P3: the same kg and date formats are coded several times, and the copies disagree**
    - **What this is:** CLAUDE.md §5.6 fixes units and "14 Feb" dates. Each screen formats them itself.
    - **Problem:**
      - Mobile kg: `features/qc_home/qc_common.dart:391` `kgText` (`'#,##,##0.###'`) vs `features/money/money_screen.dart:68`
        `formatKg` (`'#,##,##0.#'`, also used by Sell). 12.25 kg shows "12.25" to QC and "12.3" to the farmer.
      - Mobile dates: four `DateFormat('d MMM', …)` copies (`qc_common.dart:397`, `history_screen.dart:71`,
        `farmer_home_screen.dart:167`, `moisture_screen.dart:144`).
      - Portal quantities: `DashboardPage.tsx:84` and `PlotPage.tsx:46` print the raw API string (`120000.000 kg`),
        while `batchModel.ts:36` `formatKg` prints `1,20,000 kg` for the same batch.
      - Portal dates: `FarmerPage.tsx:28` `shortDate` has no `timeZone: 'Asia/Kolkata'`, unlike `flagModel.dayMonth`.
    - **Fix:** Keep one kg helper and one date helper per app: move `formatKg` and `farmerDate` to `lib/core`, and make
      `batchModel.formatKg` the shared portal one. Delete the rest (about 30 lines).
    - **If we skip it:** The farmer and the QC officer see different weights for the same lot, which starts disputes
      at the scale.

12. **[WP-M02] [WP-M03] P3: dead code on mobile, one piece of it dangerous**
    - **What this is:** Some DAO methods and folders have no production caller (I grepped `lib/` and `test/`).
    - **Problem:**
      - `MediaDao.markUploaded` (`core/db/daos/media_dao.dart:64-69`) is used only in tests. It sets
        `UploadStatus.done` without a server confirm, and M13's `purgeConfirmed` deletes every `done` file. The first
        production caller would delete evidence the server does not have.
      - `EntriesDao.markSent` (`entries_dao.dart:46-52`) is used only in tests.
      - `features/assist/`, `features/flags/` and `features/moisture_reading/` hold only a README; the code lives in
        `officer_*`.
      - `core/rules/practice_tags.dart` has no caller in `lib/`, though its header says M07 and M10 call it. Keep it
        for the B08 fixture parity, but fix the header.
    - **Fix:** Delete the two methods (move their test setup to raw Drift writes) and the three README-only folders.
    - **If we skip it:** A later worker picks `markUploaded` because the name looks right, and photos are lost.

13. **[WP-P01] [WP-P02] [WP-P03] [WP-P04] [WP-P06] P3: dead placeholder routes and a Load-more button copied six times in the portal**
    - **What this is:** Two pieces of portal code that can be deleted.
    - **Problem:**
      - `AppRoutes.tsx:57-65` filters `NAV_ITEMS` against every `wp` value that exists, so `PlaceholderPage.tsx` and
        `NavItem.wp` never render (grepped `src` and `e2e`).
      - The Load-more button lives in `MembersPage.tsx:172` and inline in `FlagsPage.tsx:289`, `AuditLogPage.tsx`,
        `DashboardPage.tsx:580`, `BatchesPage.tsx:118` and `ReadyLotsPage.tsx:363`. The ReadyLots copy lacks
        `disabled={isFetchingNextPage}`, so a double click fetches twice.
    - **Fix:** Delete `PlaceholderPage`, the filter block and `wp`. Export `LoadMore` next to `useCursorList` and use it
      in all six places (about -60 lines).
    - **If we skip it:** Six copies drift; one already has.

14. **[WP-B08] [WP-B09] [WP-B10] [WP-B11] P3: the keyset-page helper is written three times and inlined about seven more**
    (`quality/service.py:91` `_page`, `lots_batches/service.py:380` `_page`, `registry/service.py:176` `_page`, plus
    `limit + 1` slicing in publishing, reporting ×2, rules_flags, registry ×3, notifications)
    - **What this is:** Cursor paging ("fetch `limit + 1` rows, cut, return `next_cursor`").
    - **Problem:** TODO §4 B03 says to "move cursor helpers to `core/` once a second module needs them". Ten call
      sites now need them, and two of the three helpers differ only in a `to_out` argument. A fix to the cursor rule
      (e.g. descending order) has to be made ten times.
    - **Fix:** One `keyset_page(session, query, id_column, cursor, limit)` in `core/db.py`. Delete the module copies
      (about -60 lines).
    - **If we skip it:** Paging bugs get fixed in one module and stay in the others.

15. **[WP-P03] [WP-P04] P3: the portal's mock computes shares from a different quantity than the server**
    (`apps/portal/src/mocks/handlers.ts:948`)
    - **What this is:** The MSW (Mock Service Worker) mock feeds `splitShares` with
      `lot.packed?.value ?? lot.harvested?.value`. The server uses the current intake's `received_kg`
      (Architect-Gate 2026-10-31 §1).
    - **Problem:** For a lot packed at 100 kg and received at 95 kg, `batches.test.tsx` and `batchDetail.test.tsx`
      assert shares the server would never return. TODO §4 tracks this only for the ReadyLots preview.
    - **Fix:** Have the mock use the intake's received kg; add the mock to that TODO line.
    - **If we skip it:** Portal tests stay green while the real share display is wrong.

16. **[WP-B09] [WP-B08] P3: harvest and packing kg are summed by two copies of one rule**
    (`lots_batches/service.py:657-685` `_farm_kg`, `rules_flags/service.py:345-361` `_kg`)
    - **What this is:** Both sum the live harvest/packing payloads in kg. The first comment says "same rule as
      rules_flags `_kg`".
    - **Problem:** When quintals are added (both `shortcut:` comments name that upgrade), one copy will be missed. Then
      the intake snapshot and the `quantity_mismatch` rule will disagree on the same lot.
    - **Fix:** Export one helper from `rules_flags.service` `__all__` (D-004 allows `service.py` imports) and call it
      from `create_intake`.
    - **If we skip it:** Reconciliation flags that contradict the intake record.

Left out: nothing beyond what TODO.md and the per-WP reviews already track.

## Verdict per wave (gates G2–G4 need no open P1)

- **Wave 3 (B06, B13, M02, M03, P01, P03):** two P1s, both in **M02**: finding 1 (out-of-order retry loses entries)
  and finding 2 (refresh token rotated by the background isolate signs the farmer out). M02 is listed under G2 in
  `CHECKLIST.md`, so **G2 cannot be signed** until both are fixed and tested. B06 has a P2 (finding 4) and P03 a P2
  (finding 7).
- **Wave 4 (B14, B07, B08, M07, P02, P04):** no P1. M07's undo is hurt by finding 1, but the fix belongs to M02.
  P04 has P3s only.
- **Wave 5 (B09, B15, B16, M08–M11, P05, P06, P08):** no P1. M11 has a P2 (finding 5); B09 has P3s (findings 8, 16).
- **Wave 6 (B10, B11, M12, W03):** no P1. B10/W03 have two P2s (findings 3 and 6). Close finding 3 before G4 is signed,
  even though it does not block the gate: the "second line of defence" TODO §4 relies on does not exist on the
  publish path.

Verdict: fix findings 1 and 2 first (M02, both small, each with one test), then 3 and 4.

Lean: about -200 lines possible (findings 7, 11–14), -0 dependencies.

Not checked:
- I ran no tests or builds, and did not try races or out-of-memory under real concurrency; findings 1, 2, 4 and 8
  come from reading the code.
- Only skimmed: mobile auth screens, `core/widgets`, `core/voice`, the onboarding steps beyond `save`, and the
  grading/packing screen bodies; portal `LoginPage`, `PlotMap`, most of `SettingsPage` and the test bodies;
  `publishing/router.py`; `registry/geo.py`; the B13 YAML schema loader; the Alembic migrations.
- Finding 6 is an estimate from the fixture's per-lot history.
- I did not check iOS background behaviour.
