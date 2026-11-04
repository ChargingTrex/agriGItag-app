<!-- Purpose: go-live checklist for the pilot deployment. It carries every SEC ASVS L1 item that closes in
production infrastructure, not in the repo. Serves: docs/agents/reviews/SEC-asvs-l1.md (PARTIAL items 5-5, 7-4,
8-1, 8-2, 13-1, 13-4, 14-4, 14-5, 14-6 and N/A item 9-1), PLAN.md §13 E3, apps/api/Dockerfile (B21 sizing note),
infra/README.md "Production notes". Readers: the engineer who builds the AWS stack, and the Architect-Gate at G5. -->

# Pilot deployment checklist

Tick each line on the real stack and write the evidence next to it (a console screenshot, `curl -I` output or
a setting value). Ids in brackets are rows of `docs/agents/reviews/SEC-asvs-l1.md`.

## Edge: TLS, headers, body size

- [ ] **[9-1] TLS only.** The ALB HTTPS listener uses `ELBSecurityPolicy-TLS13-1-2-2021-06`. The HTTP listener
  only redirects to HTTPS. CloudFront uses viewer protocol `redirect-to-https` with minimum `TLSv1.2_2021`.
  Mobile prod builds use an `https://` `API_BASE_URL` (apps/mobile/README.md).
- [ ] **[14-5] Security headers on the portal and public pages.** Use a CloudFront response-headers policy on
  both behaviours:
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `X-Frame-Options: DENY`
- [ ] **[14-5] CSP for the portal.**
  `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https://tile.openstreetmap.org https://tiles.maps.eox.at <S3 host of presigned photo URLs>; connect-src 'self' https://tile.openstreetmap.org https://tiles.maps.eox.at; worker-src blob:; frame-ancestors 'none'; base-uri 'self'; form-action 'self'`.
  Why: MUI injects inline styles, and MapLibre fetches tiles and starts blob workers. Check on staging that the
  browser console shows no CSP violation.
- [ ] **[14-5] CSP for the public pages.**
  `default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src 'self' data:; frame-ancestors 'none'; base-uri 'none'`.
  Why: the page inlines its CSS and the 4 KB `page.js`, and loads photos from its own bucket path.
- [ ] **[14-5] `nosniff` on the API.** Set the ALB listener attribute
  `routing.http.response.x_content_type_options.header_value=nosniff`. Check with
  `curl -I https://<api>/v1/healthz`.
- [ ] **[5-5] Request body cap.** The largest legitimate body is the 2 MB CSV import (sync push stops at
  256 KiB; photos go straight to S3). If nginx fronts the API, set `client_max_body_size 3m;`. A bare ALB has no
  body cap, so in that case the ASGI guard from SEC 5-5 must be merged first (owner infra/B21).

## API and worker task definitions

- [ ] **[13-1] Real client IP.** Set `FORWARDED_ALLOW_IPS=*` in the api task environment. Uvicorn reads it and
  trusts `X-Forwarded-For`. This is safe only while the task's security group admits the ALB alone. Check that
  scans from two networks get separate rate-limit budgets (`reporting/service.py` `limit_scans`).
- [ ] **[14-4] `ENV=prod`** is set on api and worker, and `OTP_DEV_CODE` is absent. Note that `ENV=prod` refuses
  to start until a real `SMS_PROVIDER` is added (`core/config.py:61`). That is a go-live blocker, owner B04.
- [ ] **[14-4] `JWT_SECRET`** comes from Secrets Manager or SSM through the task definition's `secrets` block,
  never from an env file or the image. Make it at least 32 bytes (`openssl rand -base64 48`).
- [ ] **[13-4] Celery `visibility_timeout`.** The task definition cannot set this. Confirm that the code fix is
  merged: `broker_transport_options={"visibility_timeout": 300}` in `agritrace/worker/__init__.py`, plus
  `expires=OTP_TTL` on the OTP task (owner B04/B02).
- [ ] **Sizing (`apps/api/Dockerfile`, B21).** Set `WEB_CONCURRENCY` to the api task's vCPU count. The
  connection budget is: api tasks at autoscaling max × `WEB_CONCURRENCY` × 15 (pool 5 + overflow 10) + worker
  tasks × Celery concurrency (default = vCPU) + about 12 headroom ≤ Postgres `max_connections`. Read the real
  value with `SHOW max_connections;`. Example: 2 api tasks × 4 × 15 + 2 workers × 2 + 12 = 136, which needs
  more than the stock 100.
- [ ] **[14-6] (advisory) Swagger.** Add an ALB rule that returns a fixed 404 for `/docs` and `/openapi.json`,
  or set `docs_url=None` when `ENV=prod` (owner B00).
- [ ] **CloudFront invalidation on publish (PLAN §13 E3).** Set `CLOUDFRONT_DISTRIBUTION_ID` on the **worker**
  (the build runs there) and on the api. Give the worker's IAM role `cloudfront:CreateInvalidation` on that
  distribution. Set `PUBLIC_BASE_URL` to the CDN domain. Check that a rebuild shows the new page within 60 s.
- [ ] **Celery beat (B24, DPDP runbook §3).** Exactly **one** worker task runs the embedded beat, which fires
  the daily `registry.purge_otp_challenges`:
  `command: celery -A agritrace.worker worker --beat --schedule /tmp/celerybeat-schedule --loglevel=INFO`.
  The schedule file goes in `/tmp`, because the image's user `app` cannot write in `/app`. Every other worker
  task runs without `--beat`. Check the worker log for `beat: Starting...`.

## Database

- [ ] **[7-4] Role split.** Run migrations as the table-owner role. Run the api and worker as a separate
  non-owner role, so they cannot `ALTER TABLE … DISABLE TRIGGER`:

```sql
CREATE ROLE agritrace_app LOGIN PASSWORD '<from the secret store>';
GRANT USAGE ON SCHEMA public TO agritrace_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO agritrace_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO agritrace_app;
ALTER DEFAULT PRIVILEGES FOR ROLE agritrace IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO agritrace_app;
ALTER DEFAULT PRIVILEGES FOR ROLE agritrace IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO agritrace_app;
```

  The api and worker `DATABASE_URL` use `agritrace_app`. The migration job's `DATABASE_URL` uses the owner.
- [ ] Storage encryption is on at rest (RDS KMS) and the region is India (Arch §Security).

## Buckets

- [ ] **[8-2] `id-docs` encrypted.** Do this before `id_document_capture` is turned on, together with the
  12-2 size fix:
  `aws s3api put-bucket-encryption --bucket id-docs --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"<key arn>"},"BucketKeyEnabled":true}]}'`.
  Apply the same to `evidence`. Keep the public access block on `id-docs`.
- [ ] **[8-1] `evidence` write-once.** Set object lock to `COMPLIANCE` with the retention the FPO board signs
  (`docs/ops/dpdp-data-subject-runbook.md` §3):
  `aws s3api put-object-lock-configuration --bucket evidence --object-lock-configuration '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Days":<n>}}}'`.
- [ ] `public-pages` is served only through CloudFront. Leave its versioning on, because the DPDP runbook
  deletes old versions by key.

## Not closed by deployment

These need code or product decisions, so they are tracked in `TODO.md`, not here: P1-1 refresh re-auth (B23),
B24 export/erasure routes (the DPDP runbook is manual until then), 2-4 per-IP OTP limit, 2-5 SMS risk acceptance (D-024), 3-7 and 3-8 session idle
limits, 8-6 `S. No.` linter rule, 12-2 ID-doc presign length, and 13-5 OTP timing.
