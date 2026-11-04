<!-- Purpose: runbook to export, erase or anonymise one farmer's personal data under India's DPDP Act 2023,
without breaking the append-only traceability record: the audited routes first (B24, D-065), manual SQL as the
fallback. Serves: SEC review P1-2 (ASVS 8.3.2, item 8-4),
TODO.md §4 "Compliance (F5, DPDP Act 2023)", Arch §Security, privacy and consent, CLAUDE.md §6, D-005, D-008.
Readers: the FPO data officer (approves) and the on-call engineer (runs the commands). -->

# DPDP data-subject runbook: export, erase, retention

**Who does what.** The FPO data officer checks who is asking, logs a request reference (e.g. `DPDP-2026-001`)
and approves it. The on-call engineer runs the steps. A second person reads the row counts before `COMMIT`.
Aim to answer within 30 days. Ask counsel for the legal maximum under the DPDP Rules.

**Where to run.** On the pilot stack, use `psql` as the table-owner role. Locally that is
`docker compose -f infra/docker-compose.yml exec db psql -U agritrace agritrace`. Use `aws` with the bucket
names in `infra/docker-compose.yml` (`id-docs`, `evidence`, `public-pages`). Locally, add
`--endpoint-url http://localhost:4566` (LocalStack, key `test`/`test`, region `ap-south-1`). Every SQL block
below starts with:

```sql
\set fid '<farmer uuid>'
\set ref 'DPDP-2026-001'
```

## 1. Export one farmer's data

An FPO admin of the farmer's FPO calls the audited route (B24). It writes an `audit_log` row `farmer.export`:

```bash
curl -fsS -H "Authorization: Bearer $ADMIN_TOKEN" "$API/v1/farmers/$FARMER_ID/export" > farmer-export.json
jq -r '(.id_documents[], .evidence_photos[]) | "\(.object_key) \(.url)"' farmer-export.json |
  while read -r k u; do mkdir -p "export/$(dirname "$k")"; curl -fsS -o "export/$k" "$u"; done
```

The file links expire after 15 minutes (`links_expire_at`). If they expire, call the route again. The JSON
holds the same sections as the SQL below. Keep the SQL as the fallback when the API is down:

```sql
\pset tuples_only on
\pset format unaligned
\o farmer-export.json
WITH f AS (SELECT * FROM farmers WHERE id = :'fid'),
     my_plots AS (SELECT id FROM plots WHERE farmer_id = :'fid'),
     my_lots AS (SELECT id FROM lots WHERE farmer_id = :'fid'),
     my_versions AS (
       SELECT v.* FROM event_versions v JOIN events e ON e.id = v.event_id
       WHERE e.plot_id IN (SELECT id FROM my_plots) OR e.lot_id IN (SELECT id FROM my_lots)
          OR v.on_behalf_of_farmer_id = :'fid' OR v.entered_by_user_id = (SELECT user_id FROM f))
SELECT jsonb_pretty(jsonb_build_object(
  'farmer', (SELECT to_jsonb(f) FROM f),
  'user', (SELECT to_jsonb(u) - 'pin_hash' FROM users u WHERE u.id = (SELECT user_id FROM f)),
  'plots', (SELECT jsonb_agg(to_jsonb(p) - 'pin' - 'walked_boundary' || jsonb_build_object(
              'pin', ST_AsGeoJSON(p.pin)::jsonb, 'walked_boundary', ST_AsGeoJSON(p.walked_boundary)::jsonb))
            FROM plots p WHERE p.farmer_id = :'fid'),
  'consents', (SELECT jsonb_agg(to_jsonb(c)) FROM consent_records c WHERE c.farmer_id = :'fid'),
  'id_documents', (SELECT jsonb_agg(to_jsonb(d)) FROM id_documents d WHERE d.farmer_id = :'fid'),
  'lots', (SELECT jsonb_agg(to_jsonb(l)) FROM lots l WHERE l.farmer_id = :'fid'),
  'intakes', (SELECT jsonb_agg(to_jsonb(i)) FROM lot_intakes i WHERE i.lot_id IN (SELECT id FROM my_lots)),
  'batch_shares', (SELECT jsonb_agg(to_jsonb(s)) FROM batch_shares s WHERE s.farmer_id = :'fid'),
  'event_versions', (SELECT jsonb_agg(to_jsonb(v) - 'gps' || jsonb_build_object('gps', ST_AsGeoJSON(v.gps)::jsonb))
                     FROM my_versions v),
  'evidence_photos', (SELECT jsonb_agg(jsonb_build_object('bucket', p.bucket, 'object_key', p.object_key))
                      FROM evidence_photos p WHERE p.event_version_id IN (SELECT id FROM my_versions)),
  'assist_sessions', (SELECT jsonb_agg(to_jsonb(a) - 'started_gps') FROM assist_sessions a WHERE a.farmer_id = :'fid'),
  'audit_log', (SELECT jsonb_agg(to_jsonb(a) - 'gps') FROM audit_log a
                WHERE a.on_behalf_of_farmer_id = :'fid' OR a.entity_id = :'fid'
                   OR a.entity_id = (SELECT user_id FROM f) OR a.entity_id IN (SELECT id FROM my_plots))));
\o
```

With the SQL fallback, fetch the files yourself (`FPO_ID` is `farmers.fpo_id`; ID-document keys are
`<fpo_id>/<farmer_id>/<doc>.<ext>`):

```bash
aws s3 cp --recursive "s3://id-docs/$FPO_ID/$FARMER_ID/" export/id-docs/
jq -r '.evidence_photos[]? | "\(.bucket) \(.object_key)"' farmer-export.json |
  while read -r b k; do aws s3 cp "s3://$b/$k" "export/$b/$k"; done
```

**Redaction.**

- *To the farmer.* Give everything. Officers appear only as ids, never as names or phones.
- *To a third party.* Only with an unrevoked `partner_share` consent and the data officer's written approval.
  Never give the phone, ID documents, survey number or exact boundary (CLAUDE.md §6). Round pins to 3 dp:

```bash
jq 'del(.user, .id_documents, .audit_log, .assist_sessions, .plots[]?.land_record_ref,
        .plots[]?.walked_boundary, .event_versions[]?.gps)
    | .plots[]?.pin.coordinates |= map(. * 1000 | round / 1000)' farmer-export.json > third-party.json
```

## 2. Erase or anonymise on request

1. Run §1 first and offer the copy to the farmer. Ask the field officer to sync the farmer's phone. After
   step 2 the device is signed out, and any unsent entries stay on the phone (D-029).
2. An FPO admin of the farmer's FPO calls the audited route (B24, D-065). `reason` is kept for good in the
   audit trail, so write the request reference and approver there, never personal data:

```bash
curl -fsS -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json' \
  -d '{"reason": "DPDP-2026-001, approved by the data officer", "confirm": true}' \
  "$API/v1/farmers/$FARMER_ID/erase"   # 204; a second call is also 204 and changes nothing
```

   In one transaction, the route runs the SQL below. It changes nothing in `events`, `event_versions` or the
   audit rows already written. In `consent_records` it sets only `revoked_at`. Then it deletes every
   `id-docs` object (all versions) under `<fpo_id>/<farmer_id>/`, so step 3 is covered. It also queues a page
   build (`trigger = erase`) for each published batch with the farmer's lots, so step 4's
   `POST /v1/batches/{id}/rebuild` is covered.
   The audit row `farmer.erase` holds the reason and the row counts. Read it with
   `SELECT diff FROM audit_log WHERE action = 'farmer.erase' AND entity_id = :'fid';`.
   It differs from the SQL in five ways. Page snapshots lose the name and `gi_authorised_user_no` by lot
   code, not by name. `farmers.gi_authorised_user_no` is cleared too. `farmers.address` keeps the village,
   block, taluk, district and state, and loses only `pin`. If the address is cleared, the rebuilt page fails
   its place check and the old page, which still shows the name, stays online. With the SQL fallback, use
   `address = address - 'pin'` instead of `address = NULL`. The farmer membership is deleted. If
   the account still has another membership (an office role, or a farmer of another FPO), the `users` row,
   its OTP challenges and notifications are kept, and the data officer handles that account by hand.
   Use the SQL only when the API is down. Read each row count before `COMMIT`. The `consent_records` update
   writes the same column as `POST /v1/consents/{id}/revoke`. Raw SQL bypasses the ORM audit listener, so
   the last statement writes the audit row.

```sql
BEGIN;
UPDATE page_builds pb SET snapshot = jsonb_set(pb.snapshot, '{lots}', (
    SELECT jsonb_agg(CASE WHEN l->>'farmer_name' = (SELECT name FROM farmers WHERE id = :'fid')
                          THEN jsonb_set(l, '{farmer_name}', 'null') ELSE l END ORDER BY n)
    FROM jsonb_array_elements(pb.snapshot->'lots') WITH ORDINALITY AS t(l, n)))
  WHERE pb.snapshot ? 'lots' AND pb.batch_id IN (SELECT batch_id FROM batch_shares WHERE farmer_id = :'fid');
UPDATE consent_records SET revoked_at = now(), updated_at = now() WHERE farmer_id = :'fid' AND revoked_at IS NULL;
UPDATE devices SET revoked_at = now(), refresh_token_hash = NULL, previous_refresh_token_hash = NULL
  WHERE user_id = (SELECT user_id FROM farmers WHERE id = :'fid');
DELETE FROM otp_challenges
  WHERE phone = (SELECT u.phone FROM users u JOIN farmers f ON f.user_id = u.id WHERE f.id = :'fid');
DELETE FROM notifications WHERE user_id = (SELECT user_id FROM farmers WHERE id = :'fid');
UPDATE users SET phone = 'erased:' || id, name = 'Erased farmer', name_local = NULL, pin_hash = NULL,
                 status = 'suspended' WHERE id = (SELECT user_id FROM farmers WHERE id = :'fid');
UPDATE farmers SET name = 'Erased ' || code, name_local = NULL, photo_key = NULL, address = NULL,
                   status = 'suspended' WHERE id = :'fid';
UPDATE plots SET land_record_ref = NULL WHERE farmer_id = :'fid';
UPDATE plot_revisions SET snapshot = snapshot - 'land_record_ref'
  WHERE plot_id IN (SELECT id FROM plots WHERE farmer_id = :'fid');
DELETE FROM id_documents WHERE farmer_id = :'fid';
INSERT INTO audit_log (id, at, action, entity_type, entity_id, diff)
  VALUES (gen_random_uuid(), now(), 'farmer.erase', 'farmers', :'fid', jsonb_build_object('request_ref', :'ref'));
COMMIT;
```

3. SQL fallback only (the route already did this): delete the ID documents with
   `aws s3 rm --recursive "s3://id-docs/$FPO_ID/$FARMER_ID/"`. If `id-docs` is versioned on AWS, also delete
   the old versions, as in step 4.
4. Rebuild the public pages. Find the batches with
   `SELECT DISTINCT b.id, b.code FROM batches b JOIN batch_shares s ON s.batch_id = b.id WHERE s.farmer_id = :'fid' AND b.status = 'published';`.
   With the SQL fallback, an FPO admin calls `POST /v1/batches/{id}/rebuild` for each one (the route has
   already queued them). Poll `GET /v1/batches/{id}/builds` until the latest build reads `built`. The consent
   is now withdrawn, so the page shows "Farmer N" (W01/B10). The build invalidates CloudFront by itself.
   Then delete the older page versions that still hold the name. The route does not do this step:

```bash
for k in index.html data.json; do
  aws s3api list-object-versions --bucket public-pages --prefix "batches/$CODE/$k" \
    --query 'Versions[?IsLatest==`false`].VersionId' --output text | tr '\t' '\n' |
  while read -r v; do [ -n "$v" ] && [ "$v" != None ] &&
    aws s3api delete-object --bucket public-pages --key "batches/$CODE/$k" --version-id "$v"; done
done
```

5. On the farmer's phone, the field officer clears the app's storage. Then the officer checks one officer phone
   after its next sync: entries should show "Erased farmer".

**What stays, and why.** These records are the lawful traceability record. After erasure they carry only ids.

- `events`, `event_versions`, `lots`, `lot_intakes`, `batch_shares`, `batches` and `quality_readings` are the
  GI 883 provenance record. They are append-only (D-005). `entered_by_user_id` now resolves to "Erased farmer".
- `consent_records` is the lawful-basis trail: what was agreed, when, who witnessed it, and when it was
  withdrawn.
- `plots.pin` and `walked_boundary` are the GI-region evidence. They never reach a public page (CLAUDE.md §6).
- `evidence` photos are under object lock (D-008) until the retention ends. If a photo shows the person, the
  data officer records it, and the photo is deleted when the lock ends.
- **Residual:** `audit_log.diff` (create and update rows of `users`, `farmers` and `plots`) and the free text in
  `event_versions.reason_text` and `payload` keep the old phone, name, address and survey number. Both are
  immutable (trigger `audit_log_append_only`). TODO (owner **Architect-Gate + SEC**): rule on a D-005 exception
  before anyone redacts. If allowed, the owner role runs it in one transaction:
  `ALTER TABLE audit_log DISABLE TRIGGER audit_log_append_only;` then set each of those keys to `"[redacted]"`
  for rows whose `entity_id` is the farmer, their user or their plots, then `ENABLE TRIGGER`. This depends on
  the DB role split (deployment checklist, SEC 7-4).

## 3. Retention defaults

No source document fixes retention periods. The Architecture says only "nothing is hard-deleted except on a
valid data-deletion request". The rows below are **proposals**. They take effect when the FPO board signs
them; the data officer then records the signed table in `TODO.md`.

| Data | Proposed default | Approves |
|---|---|---|
| `otp_challenges` | Purge 30 days after expiry: Celery beat task `registry.purge_otp_challenges`, daily 02:30 UTC, `OTP_RETENTION_DAYS` (B24). Needs a beat process (`celery -A agritrace.worker beat`) | Data officer |
| `id_documents` and `id-docs` | Delete once the farmer is verified, and always when the farmer leaves | Data officer |
| Phone, name, address (`users`, `farmers`) | While a member. Erase on request, or 1 year after leaving | FPO board |
| Traceability record, `evidence`, `audit_log`, `consent_records` | Last batch's `best_before_date` + the certification audit window; personal data scrubbed as in §2 | FPO board + compliance owner |
| Public pages (`public-pages`) | While packs with the QR can be on sale | FPO board |

Each erasure request is approved by the data officer. Any change to this table, and any audit-log redaction,
needs the FPO board and the Architect-Gate.
