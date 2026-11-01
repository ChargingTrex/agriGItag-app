# Q06-1 (P3): consent audit rows never appear in `GET /v1/audit-log`

<!-- Purpose: observation found while automating the B02 consent line (docs/agents/reports/Q06.md). Serves:
docs/agents/qa-rubric.md. Readers: Orchestrator, BE/SEC Reviewers, owners of B11 (reporting, D-039) and B02 (consent). -->

**Found by:** QA Lead (Q06), 2026-11-02, image built from `8dc2a41`, isolated compose stack `agritrace-q06`, fresh seed.
**Severity:** P3. No acceptance line fails and nothing is lost: the rows are written (B02 line "consent writes audit
row with actor=officer" passes on the database). But the FPO admin's audit viewer (D-039, FR-21/FR-41) cannot show
who recorded, revoked or witnessed a farmer's consent, which is the record most likely to be asked for in a dispute.
**Owner:** B11 (`apps/api/agritrace/modules/reporting/service.py` `_owned_by`, D-039).

## Reproduction
1. Field officer `+919000000002` starts an assist session for a farmer of the demo FPO (`POST /v1/assist/start`)
   and records a consent with `X-Assist-Session` (`POST /v1/consents`) → 201, consent id `C`.
2. `select actor_user_id, on_behalf_of_farmer_id, assist_session_id from audit_log where entity_id = 'C'` → one row
   (officer, farmer, session), `entity_type = consent_records`.
3. As FPO admin `+919000000001`: `GET /v1/audit-log?entity_id=C` → 200 with `items: []`; the unfiltered newest page
   also never lists `consent_records` rows.

## Cause
`_owned_by` scopes audit rows to tables that have an `fpo_id` column (plus `fpos` and `event_versions`).
`consent_records` has no `fpo_id` (it hangs off `farmers`), so its rows match no clause. D-039's COMPROMISE names
"untenanted tables (users, devices)", not consents. Fix in one place: add a clause for `consent_records` joined
through `farmers.fpo_id` (as `event_versions` is joined through `events`), or set `audit_log.fpo_id` as the D-039
shortcut comment already proposes.

## Robot
`qa/robot/api/identity.robot` reads the consent rows from the database (keyword `Audit Rows Of`) and passes; switch it
to `GET /v1/audit-log?entity_id=` once this is fixed.
