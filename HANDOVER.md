# Handover — AgriTrace build, state at 2026-11-05 00:30 IST (end of day 5; stopped by the user with Q01 mid-flight)

Written for: whoever resumes the multi-agent build (human or the Orchestrator session). Read this, then `CHECKLIST.md`, then `TODO.md` §4, §6–§8 and the decision-number ledger line.

## 1. Where things stand

| Area | State |
|---|---|
| Remote | `origin` = https://github.com/ChargingTrex/agriGItag-app (**public**; the tree holds only the fake `+919000…` seed numbers and `.env.example`). Push after every merge: `git push origin main` |
| Progress | `CHECKLIST.md`: **95 % (79/83)**. Open: **Q01** (device checks, mid-flight on the stand-in AVD), Q04 (CONDITIONAL on the BM-07 first-run, unspent), Q05 (CONDITIONAL), G3 (blocked on Q01 + AAB figure). Merged today: P12 (device management screen), B25 (CSV per-row errors + one audit helper), B24 (export/erase endpoints + OTP purge; D-065 Proposed), compose worker runs beat |
| Gates | G0, G1, G2, G4 SIGNED; G5 signed CONDITIONAL (`docs/agents/gates/G5.md`: A = Q01 on a Go AVD incl. AAB ≤ 30 MiB, B = BM-07 first run after B22/B23, C = human items). G3 BLOCKED on Q01 + AAB |
| Decisions | D-001…D-054 accepted, **D-065 Proposed** (B24 anonymisation choices + the "Farmer N" page still shows village, farm area and a ~110 m map point — needs the Architect-Gate ruling); D-055–D-064, D-066 reserved/unused. Next free: **D-067** |
| Main | 516 commits; backend 638 unit (branch runs; the full suite on main after B24/B25 **has not run** — Docker died); mobile analyzer clean after the regenerated Dart client (B24 routes); portal 19/19 members tests on the P12 branch (full portal suite on main after P12 **not run**); clients regenerated and committed at ef9dac4 |
| Stack | **Docker Desktop crashed at ~00:05 IST because the host disk filled (344 MiB free; swap 15 GB): the Docker VM logged ext4 I/O errors.** Expect the next start to need the repair notes (§4.6; a truncated-snapshot repair or a GUI purge may be needed; named volumes hold only seed data, except `sih_byteforce_apix-data` from another project — back it up first: `~/docker-volume-backup-2026-11-01/` has an older copy). At close the Orchestrator deleted `apps/mobile/build` and ran `uv cache clean`. The api/worker image on disk is from 17:08Z (pre-B24/B25); the compose worker command now carries `--beat`. `infra/.env` (git-ignored): `DB_PORT=5433`, `API_PORT=8001` (another project's Django app owns :8000). Reseed before any demo |
| Emulator | AVD `agritrace_go` (`~/.android/avd/agritrace_go.avd`): **API 36.1 google_apis_playstore x86_64 stand-in** with the Go constraints (2 GB, 2 cores, 720×1280 @ 320 dpi). The plan's API 27 image is a human step (SDK licences; TODO line). It may still be running at hand-over (`adb emu kill`) |

## 2. In flight at hand-over

| Agent | What | Resume |
|---|---|---|
| Q01 Verifier | **finished PARTIAL at 2655166** (`docs/agents/qa/Q01.md`, resume commands at the top): PASS — airplane save + photo queued, "Phone is full" sheet at 61 MB keeps the unsent photo, undo at 24 h ± 1 min, WorkManager job registered, dev build signs in over 10.0.2.2:8001; cold start 6.85–18 s on a loaded host (budget 3 s → rerun alone); remaining — send-on-restore, BM-01/02/11/12/14/15 device side, offline matrix, WorkManager firing, confirmed-photo purge, clock jump, user switch, release smoke, integration test. Airplane mode and a manual clock are still set inside the AVD | respawn a MOB Verifier with "continue Q01 from the close section" once Docker is back and the host is quiet (run alone) |

No worktrees should be open (`git worktree list` = main only).

## 3. First steps tomorrow (in order)

1. `git push origin main`; `open -a Docker`, wait for `docker info`; if it will not start, see §4.6. Then `docker builder prune -af && make up` and check `docker image inspect agritrace-api:dev --format '{{.Created}}'` is after 2026-11-04T19:00Z; confirm beat: `docker compose -f infra/docker-compose.yml logs --tail 30 worker | grep -i beat`; `curl localhost:8001/v1/healthz`.
2. Suites on main (owed since B24/B25/P12): `cd apps/api && uv run pytest tests -q -p no:cacheprovider -rfE` (expect ~820), `cd apps/portal && npm run typecheck && npm test -- --no-file-parallelism` (expect 141+). Fix forward via a hotfix WP if anything is red.
3. **BM-07 counted run (G5 condition B, unspent):** only when the 1-minute load is < 60 and the emulator is off; exact command and preconditions in `docs/agents/qa/Q04/bm07-2026-11-04.md`; resume the "Verifier BM-07 first run" brief. PASS → Q04 PASS, condition B closed.
4. **Q01** per §2; then the QA Lead un-tags the mobile Robot placeholders that passed; Architect-Gate re-evaluates G3 and G5 condition A, and rules on D-065 (village / area / map residue on the "Farmer N" page) and on the D-005 redaction question.
5. Then only human items remain (§4) and the P3 follow-ups in TODO §8.

## 4. Blockers only a human can clear

1. **Android 8 (API 27) image** for the real Go profile: `sdkmanager --licenses`, install `system-images;android-27;google_apis;x86_64`, create `agritrace_go27` (TODO line has the commands). Until then Q01 runs on the API 36.1 stand-in.
2. **bundletool CLI jar** on PATH for the AAB download size (≤ 30 MiB).
3. **Product confirmations:** farmers keep a session 90 days (staff 30; `SESSION_MAX_DAYS_FARMER`); GI 883 taluk list; 3-dp map rounding; 15 % grading-loss default; D-034 public fields; the "Farmer N" page residue (D-065); DPDP retention periods.
4. **Deployment:** `docs/ops/deployment-checklist.md`; an SMS provider before `ENV=prod`; Firebase/APNs.
5. **Host capacity:** the machine swaps when the emulator, Docker and 3+ agent test runs share it with the user's other apps (WhatsApp at 300 % CPU). Run Q01 and BM-07 alone.
6. **Docker Desktop** repair notes are in the agent memory and `docs/agents/qa/B00.md` §environment: orphan `com.apple.Virtualization` process; `docker builder prune -af` for "lease not found"; the GUI purge is a human step.

## 5. Resume procedure (Orchestrator)

1. `git status` clean on `main`; Docker up; healthz ok on :8001.
2. New WP or hotfix: one Opus Worker in a worktree with declared paths and a reserved decision number (next D-067) → Reviewer with the right hat (`ponytail:ponytail-review`; SEC hat for auth, sync, presign, public payloads, locks, anything touching personal data) → exact fixes confirmed by the Orchestrator, new logic back to the same reviewer → merge `--no-ff` → regenerate (`export_openapi`, `gen-error-codes.py`, `npm run gen:api`, `tool/gen_api.sh` with `JAVA_HOME`) → `make up` → suites on main → CHECKLIST/CHANGELOG/TODO → `codegraph sync .` → remove worktree + branch → `git push origin main`.
3. Verifiers that sign staff in or mutate seed data use an isolated compose project (`COMPOSE_PROJECT_NAME=agritrace-<wp> API_PORT=80xx DB_PORT=54xx REDIS_PORT=64xx S3_PORT=45xx docker compose -f infra/docker-compose.yml up -d --build --wait`, seed via `exec api`, `down -v` after).
4. Conflicts: CHANGELOG/TODO/LIBRARIES keep both sides; DECISIONS rows in number order; generated files take main's then regenerate; **code by hand**. Keep G0 = exactly {B00, Q00} in CHECKLIST. No phone outside `+919000…` in committed evidence.

## 6. Risks

- Device behaviour is still only partly verified (Q01 mid-flight, on a stand-in image).
- BM-07 depends on host quiet and the rules backlog; B22 cut the per-check cost 3× but the first-run condition is unspent.
- Publish answers 202 before the page build succeeds; a privacy-lint false positive fails a build (TODO §7/§8).
- The erase endpoint keeps village-level address, farm area and a coarse map point on the public page (D-065 ruling owed).
- Seed-state pollution on the shared stack; OTP caps (10/phone/day) limit live staff checks.
