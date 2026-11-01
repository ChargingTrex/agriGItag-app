# Gate G5 — Pilot candidate: readiness report (Q05)

<!-- Purpose: the Q05 Verifier's evidence report for gate G5 (PLAN.md §3, §7.5 Q05, §10 step 4). The Architect-Gate
signs docs/agents/gates/G5.md from it. Serves: CHECKLIST "Gate G5 signed" and the two G5-condition rows. Readers:
Architect-Gate, Orchestrator, QA Lead, all Reviewers. Written by the Q05 Verifier; changes no code. -->

**Status: CONDITIONAL at best. Not signable today.** Tree: `main` @ `06b71f4`, 2026-11-02 (21:03–21:25Z).

Q01 (the device checks on the Go AVD) has not started, and no AVD exists on this host. The mobile half of the pilot has
passed its unit, widget and integration suites, but it has never run on a device profile. Some G5 conditions below are
unmet for that reason alone. Others are unmet for reasons unrelated to devices: CHECKLIST is at 90 %, 32 Robot
placeholders remain, there is no wave-7 `/ponytail-audit`, and the G5 SEC and DOCS passes have not run.

## 1. Conditions (PLAN §3 row G5, the §3 every-gate rules, §10 step 4 G5 extras, CHECKLIST G5 rows)

| # | Condition | Met? | Evidence |
|---|---|---|---|
| 1 | All WPs: Reviewer PASS + Verifier PASS, merged | **Unmet** | §2 below. 5 WP rows are unticked: P06, Q01, Q03, Q04, Q05. G3 and G4 are not signed (both readiness files say BLOCKED) |
| 2 | `/ponytail-audit` clean of P1 on the merged tree | **Partly met** | §3. Both audit files (waves 0–2 and 3–6) list 5 P1s, and all 5 are fixed and merged (P09, M14, M16). **No audit covers wave 7**: B12, B17–B21, M13, P07, P10, P11, Q06, Q07. The waves-3-6 audit only glanced at M13 where it touches M02. PLAN §3 asks for an audit on the merged tree, so a final `/ponytail-audit` is still owed |
| 3 | Security checklist (SEC review, OWASP ASVS L1 over identity, sync, presigned URLs, tenant scoping; PLAN §10.4) | **Unmet** | §4. 13 reviews were done with a SEC hat, and all are PASS or fixed to PASS. There is **no ASVS L1 pass as one document**, and two TODO items were deferred to "the SEC pass before G5" and are still open |
| 4 | Docs coverage script 100 % (BM-10) | **Met** | `python3 infra/scripts/doc-coverage.py` exits 0. Interrogate is 100 % on `apps/api` and `apps/public-page`. `flutter analyze` with `public_member_api_docs` reports "No issues found". Portal eslint-plugin-jsdoc passes. DECISION ids: 163, 0 unknown. File headers: 912, 0 missing ([Q05/logs/10](../qa/Q05/logs/10-doc-coverage.txt), [11](../qa/Q05/logs/11-interrogate-and-lint-config.txt)) |
| 4b | DOCS review: the README 5-minute start works from a clean clone (PLAN §10.4) | **Not run** | no DOCS-review file exists in `docs/agents/reviews/` |
| 5 | CHECKLIST shows 100 % | **Unmet: 90 % (69/77)** | read-only count, the same regex as `checklist-progress.py` ([Q05/logs/15](../qa/Q05/logs/15-checklist-completion.txt)). Unticked: P06, G3, G4, Q01, Q03, Q04, Q05, G5 |
| 6 | Robot suites for the finished WPs green, with no placeholders (`gate-readiness.py G5`) | **Unmet** | §5. API **67/67** (Q06), portal P01–P04 **12/12** (Q07 r1). `gate-readiness G5` exits 1 with 42 lines, which are **32 unique placeholder tests**. Among them are all 6 of `e2e/reference_batch.robot`, the suite §9.1 assigns to G5 ([Q05/logs/12](../qa/Q05/logs/12-gate-readiness-G5.txt)) |
| 7 | `docs/LIBRARIES.md` in sync | **Met** | `libraries-check: PASS (171 ledger rows)` ([Q05/logs/13](../qa/Q05/logs/13-libraries-check.txt)) |
| 8 | `docs/api/error-codes.md` regenerated, no unregistered code | **Met** | `gen-error-codes.py --check`: "current (50 codes)" ([Q05/logs/14](../qa/Q05/logs/14-error-codes-check.txt)) |
| 9 | Benchmarks BM-01…BM-16 (Q05 sweep) | **Unmet: 9 PASS, 1 incomplete, 6 not run** | §6; [benchmarks.json](../qa/benchmarks.json); [Q05/logs/20](../qa/Q05/logs/20-benchmarks-collect.txt) |
| 10 | CHECKLIST G5 condition (rulings 2026-10-31 §4): B15, M02 r2 and M09 r2 merged before onboarding/assist runs on a field device | **Met** (row ticked) | `docs/agents/qa/B15.md`: live push `[farmer, assist_session, consent, plot]` → 4 × accepted, replay → 4 × duplicate |
| 11 | CHECKLIST G5 condition (rulings 2026-10-31b §1): B16 and M11 r2 merged before QC intake runs on a field device | **Met** (row ticked) | `docs/agents/qa/B16.md` (live `lot_intake` pushes; the B16-1 race closed by B19, 5/5 live) |

## 2. Work packages (CHECKLIST.md at `06b71f4`)

- **Ticked, with Reviewer and Verifier evidence on record:** all backend WPs B00–B21, P00–P05, P07–P11, W01–W03, Q00,
  Q02, Q06, Q07, and M00. B21 was confirmed live by this run: [Q04.md §Re-verified after B21](../qa/Q04.md).
- **Ticked, but "Verifier" means an Orchestrator-run suite, with device checks deferred to Q01:** M01–M12, M14, M15 and
  M16; M13's size line was run by the Orchestrator. They count as verified for code, not for devices.
- **Reviewer was the Orchestrator** (test-only or QA code, by the role card's exception): B17, M15, P11, Q06, Q07.
- **Unticked:**
  - **P06:** 4/5 lines live. Line 5 (audit search shows actor + reason) is fixed by B20 and proven in the DB. The portal
    re-check is pending, in Q07 round 2.
  - **Q01:** not started. There is no worker and no AVD on the host.
  - **Q03:** CONDITIONAL. P2 Q03-1: its two `public/page.robot` tests are still placeholders.
  - **Q04:** was FAIL. After B21 it is **CONDITIONAL** (this run): no 5xx; BM-07 PASS on run 3; Q04-3 is kept as a flaky P2.
    The Orchestrator updates the row.
  - **Q05:** this report. Verdict in [Q05.md](../qa/Q05.md).
- **Gates:** G0, G1 and G2 are signed. G3 and G4 have readiness files saying BLOCKED (`G3.md`, `G4.md`). G5 needs both of
  them closed first, because G5's scope is "all WPs".

## 3. `/ponytail-audit` status

| Audit | P1 | Fixed by (merged) |
|---|---|---|
| [wave-0-2.md](../audits/wave-0-2.md) | 1. P01: a browser left signed in locks other staff out on a shared PC | **P09**: on `device_in_use`, a new device id and a retry; sign-out failure surfaced (merged 2026-11-01) |
| | 2. M02: photos never upload while the phone clock runs ≥ 14 min fast | **M16**: upload-URL expiry vs clock skew (merged 2026-11-01) |
| | 3. M02: a running sync pushes A's entries with B's token after a user switch | **M16**: a running sync stops on user switch (merged 2026-11-01) |
| [waves-3-6.md](../audits/waves-3-6.md) | 1. M02: a retry after a failed push sends entries out of order, and the server rejects them for good | **M14**: the outbox retries in strict order; ordering rejections are retried (merged 2026-11-01) |
| | 2. M02: background sync rotates the refresh token, the foreground keeps the old one, and the farmer is signed out | **M14**: the refresh token is re-read from secure storage (merged 2026-11-01) |

All 5 P1s are closed in code and unit-tested (M14/M16: Flutter suite 812/812). Their device proofs (clock jump,
user switch mid-sync, WorkManager background refresh) are Q01 work. **Gap:** the wave-7 code has no audit. That
code is B12, B17–B21, M13, P07, P10, P11, and the Q06/Q07 QA code. `/ponytail-debt` → TODO §3 is also not re-run for wave 7.

## 4. Security checklist: what the SEC-hat reviews covered

| WP | Review | Verdict | Covered |
|---|---|---|---|
| B02 | B02-r1 (ASVS 4.0.3 L1 lens), r2 | FAIL → PASS-PENDING-STACK | OTP/PIN, refresh cookie vs body, revoked token revival (`signed_in_at`), PIN change, secrets in logs (CWE-532). 13 P3s deferred to "the SEC pass before G5" (TODO line 120, open) |
| B06 | B06-r1 | PASS-PENDING-STACK | sync push identity/assist fields in event bodies, presigned photo PUT, evidence write-once |
| B10 | B10-r1 (SEC/privacy) | PASS-PENDING-STACK | published page and partner payload privacy (lint with canaries), no personal data in output |
| B16 | B16-r1 | PASS-PENDING-STACK | QC-only `lot_intake` and `/intakes`, FPO scoping of processor and intake |
| B18 | B18-r1 | PASS | presigned PUT bound to Content-Length + size ceiling, bounded verify read, lint-on-publish |
| B21 | B21-r1 | PASS | NUL/int32 at the push boundary, the class-22 backstop scope, DoS via deep nesting (P2-1 fixed) |
| M06 | M06-r1 (+r2 confirm) | FAIL → PASS | tokens only in the keystore, bearer sent only to the API host, device binding, PIN |
| M10 | M10-r1 (+r2 confirm) | FAIL → PASS | assist-mode guard and recording (CLAUDE.md §6), privacy of farmer data on the officer phone |
| M13 | M13-r1 | PASS | session storage: no token columns in Drift v3, flutter_secure_storage only |
| M14 | M14-r1 | PASS | refresh-token rotation between isolates |
| M16 | M16-r1 | PASS | another user's tokens never adopted (JWT `sub` check), sync stops on user switch |
| P09 | P09-r1 (+r2 confirm) | FAIL → PASS | portal shared-PC device lockout, OTP/device-binding retry security |
| P10 | P10-r1 | PASS | masked phone, audited Reveal, the number does not survive leaving the page |

**Gaps.**
1. **No OWASP ASVS L1 pass as one document** over identity, sync, presigned URLs and tenant scoping, as PLAN §10.4 asks.
   The coverage is spread over 13 reviews, and only B02-r1 used an ASVS lens explicitly.
2. **Tenant scoping has no cross-cutting review.** It was checked WP by WP (B16, B14 via P10), but no single pass looked at every
   router for `fpo_id`/role scoping. Q06-1 (P3) found consent audit rows without `fpo_id`.
3. **TODO line 97 is open** (DPDP Act: erasure runbook for append-only tables; the API DB role must not own the tables;
   audit-diff redaction). Its owner is "SEC review before G5".
4. **TODO line 120 is open** (the 13 B02 P3s).
5. No dependency-vulnerability scan (pip-audit, npm audit, osv-scanner) is on record.

## 5. Robot suites

| Suite | Result | Evidence |
|---|---|---|
| `qa/robot/api/*` + `healthz.robot` | **67/67 PASS**, twice, on an isolated stack | `docs/agents/qa/Q06/robot/output.xml` (pass 67, fail 0, skip 0) |
| `qa/robot/portal/portal.robot` P01–P04 | **12/12 PASS**, twice | `docs/agents/qa/Q07/robot/output.xml` (pass 12, fail 0) |
| W02 public page | 11 passed, 4 skipped | `docs/agents/qa/Q03.md` |

`gate-readiness.py G5` (run `uvx --python 3.12 --from robotframework==7.5 python qa/scripts/gate-readiness.py G5`,
exit 1). These lines are pasted from [Q05/logs/12](../qa/Q05/logs/12-gate-readiness-G5.txt). Tests tagged with two WPs
appear twice, so the 42 lines are 32 unique tests:

```
NOT READY: 42 placeholder test(s) still tagged not-ready:
  B06  qa/robot/mobile/network_profiles.robot  BM-15 Same Push Replayed 5 Times Leaves One Record
  B12  qa/robot/e2e/reference_batch.robot  After Fixes Publish Succeeds With GI Verified And Shares 31.25 62.5 6.25
  B12  qa/robot/e2e/reference_batch.robot  Approve And Publish Return 409 Before Fixes
  B12  qa/robot/e2e/reference_batch.robot  Dart And TS Clients Compile
  B12  qa/robot/e2e/reference_batch.robot  Demo Seed Is Idempotent
  B12  qa/robot/e2e/reference_batch.robot  Grade A Returns 422 Unknown Grade For Profile
  B12  qa/robot/e2e/reference_batch.robot  Reference Batch Raises Exactly The Expected Flag Set
  M02  qa/robot/mobile/network_profiles.robot  BM-11 Normal 4G Entry Plus One Photo Shows Sent Within 5 s
  M02  qa/robot/mobile/network_profiles.robot  BM-12 Weak 4G Entry Plus One Photo Shows Sent Within 20 s
  M02  qa/robot/mobile/network_profiles.robot  BM-13 Airplane Mode Saves Instantly And Sends Automatically On Restore
  M02  qa/robot/mobile/network_profiles.robot  BM-14 Kill Mid Upload Then Relaunch Leaves One Entry And One Photo
  M02  qa/robot/mobile/offline_matrix.robot  Matrix On Edge
  M02  qa/robot/mobile/offline_matrix.robot  Matrix On Normal 4G
  M02  qa/robot/mobile/offline_matrix.robot  Matrix On Offline
  M02  qa/robot/mobile/offline_matrix.robot  Matrix On Reconnect After Offline
  M02  qa/robot/mobile/offline_matrix.robot  Matrix On Weak 4G
  P05  qa/robot/portal/portal.robot  CSV Export Has A Unit On Every Quantity
  P05  qa/robot/portal/portal.robot  Labels PDF Is Named Labels Batch Id
  P06  qa/robot/portal/portal.robot  Audit Search Shows The Seeded Correction With Actor And Reason
  P06  qa/robot/portal/portal.robot  Column Toggle Persists
  P06  qa/robot/portal/portal.robot  Name Opt Out Is Reflected In The Preview
  P06  qa/robot/portal/portal.robot  Stage Tiles Match Seed Counts
  P06  qa/robot/portal/portal.robot  Village Filter Updates Tiles And Table
  P07  qa/robot/portal/portal.robot  Full Chain Login To Labels Is Green Under 10 Minutes Twice
  P07  qa/robot/portal/portal.robot  No Serious Axe Violations
  P08  qa/robot/portal/portal.robot  Confirm Creates Only The Valid Rows
  P08  qa/robot/portal/portal.robot  Template Matches Config Fields
  P08  qa/robot/portal/portal.robot  Upload With 2 Bad Rows Previews 2 Red Rows With Codes
  Q01  qa/robot/mobile/network_profiles.robot  BM-11 … BM-15 (the same 5 tests as above)
  Q01  qa/robot/mobile/offline_matrix.robot  Matrix On Edge / Normal 4G / Offline / Reconnect After Offline / Weak 4G
  Q03  qa/robot/public/page.robot  Old Page Version Is Retrievable
  Q03  qa/robot/public/page.robot  Page Is Served From Object Storage With The Backend Down
  W03  qa/robot/public/page.robot  OG Tags Pass The Privacy Lint
  W03  qa/robot/public/page.robot  Tamil Renders With The System Font
gate-readiness G5: FAIL
```

The 32 by owner: mobile 10 (Q01), the B12 e2e suite 6 (no owner scheduled; the pytest e2e it mirrors passes, 781/781 in
Q04), the portal 12 for P05/P06/P07/P08 (Q07 round 2 is in progress), and the public page 4 for Q03/W03 (Q07 round 2).

## 6. Benchmarks (Q05 sweep)

Merged by `collect.py --results-dir docs/agents/qa/bench-results/` into [benchmarks.json](../qa/benchmarks.json). The
full table with sources is in [Q05.md](../qa/Q05.md). **PASS (9):** BM-03, 05, 06, 07, 08, 09, 10, 15, 16. **Incomplete
(1):** BM-04. The APK is 30.03 MiB and passes the 100 MiB budget (40 is the target). The AAB download is NOT MEASURED,
so collect.py judges BM-04 FAIL on the missing metric. **NOT RUN (6):** BM-01, 02, 11, 12, 13, 14 (device and network, Q01).

## 7. What Q01 must still prove before G5 can be signed

On the Go AVD profile `qa/avd/go_profile.ini` (API 27, 2 GB, 2 cores, 720×1280), plus the API 34 AVD:
1. **BM-01:** the 3-tap harvest flow 10×, p50 ≤ 60 s and p95 ≤ 90 s.
2. **BM-02 / BM-11:** an entry ≤ 5 s and a 300 KB photo ≤ 10 s on `normal_4g`. **BM-12:** ≤ 20 s on `weak_4g`.
3. **BM-13:** in airplane mode the entry saves at once and is sent with no user action after the network returns.
   **BM-14:** kill the app mid-upload and relaunch → 1 entry and 1 photo on the server. **BM-15** on the device (the
   server half is PASS, B06).
4. **The offline/online matrix:** 9 flows × 5 profiles (`offline_matrix.robot`, 5 placeholders), which is G3's condition.
5. **Cold start < 3 s** on the Go AVD (M13).
6. **The WorkManager 15-minute background job really fires** and syncs (M13, M14 background refresh-token path).
7. **The low-storage prompt and purge** below 100 MB (M13), including the camera-step path.
8. **Clock jump:** photos still upload with the phone clock ≥ 14 min fast or slow (M16 / audit wave-0-2 P1-2).
9. **User switch mid-sync:** a sync started for user A stops, and B's token never sends A's entries (M16 / audit P1-3).
10. The per-WP device checks deferred to Q01: camera without gallery and compression (M04), GPS ring (M09), the < 20 s
    log (M07), BLE (M11), notifications and deep links (M12), OTP auto-read (M06).
11. **BM-04 download:** `bundletool get-size total` on the release AAB for the Go AVD spec, ≤ 30 MiB. This is the human
    step in TODO "AAB download size". Its outcome also decides G3 condition 3.

## 8. Order to close G5

Q07 round 2 (P05/P06/P07/P08 and the public-page placeholders, P06 line 5) → sign G4. Q01 on the AVD (§7) → sign G3.
Then a Robot owner for `e2e/reference_batch.robot`. Then the wave-7 `/ponytail-audit` with 0 P1, and the SEC ASVS L1
pass plus TODO lines 97 and 120. Then the DOCS clean-clone README check. Then tick P06/Q03/Q04/Q05 → CHECKLIST 100 % →
G5.md.
