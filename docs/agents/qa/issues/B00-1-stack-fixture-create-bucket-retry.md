# B00-1 (P2): `stack` fixture dies with BucketAlreadyOwnedByYou when the first CreateBucket is retried

<!-- Purpose: Verifier defect report for WP B00. Serves: docs/agents/qa-rubric.md (P2 with reproduction). Readers: Orchestrator, BE Reviewer, B00 owner. -->

**Found by:** B00 Verifier, 2026-11-01, commit 5b091fd (main), host load average 85-360.
**Severity:** P2. No data loss, but one slow S3 reply errors every integration and e2e test in the session (11 of 11 B00 tests in the first run; it cascades to every WP's integration tests because they all depend on `stack`).
**Owner:** B00 (apps/api/tests/conftest.py, harness). Related: apps/api/agritrace/core/storage.py client config.

## What happens
`tests/conftest.py::stack` (line 73) calls `s3.create_bucket(Bucket="evidence", ObjectLockEnabledForBucket=True, CreateBucketConfiguration={"LocationConstraint": "ap-south-1"})`
through `storage.client()`, whose botocore config is `read_timeout=10`, `retries={"max_attempts": 2, "mode": "standard"}`.
On a loaded host the first S3 call after LocalStack prints `Ready.` can take longer than 10 s (a standalone probe with the same client config took 5.1 s for that first call at load average 108; scratch script, not committed).
botocore then retries the PUT. The first attempt already created the bucket, so the retry gets
`BucketAlreadyOwnedByYou` (outside us-east-1 S3 and LocalStack answer 409 instead of 200). The exception escapes the session fixture, and every test that requests `stack`, `migrated` or `client` errors at setup.

Rerun 1 (`logs/06b-…-rerun1.log`, line 443) shows the same first CreateBucket being retried (`Retry needed … attempt=2; max=3`); that time the retry returned 200 and the session continued.

## Reproduction
```
cd apps/api
uv run pytest tests/integration/test_healthz.py tests/integration/test_storage.py tests/integration/test_schema.py -q -p no:cacheprovider -rfE
# on a host with load average > ~80:
E   botocore.errorfactory.BucketAlreadyOwnedByYou: An error occurred (BucketAlreadyOwnedByYou) when calling the CreateBucket operation: Your previous request to create the named bucket succeeded and you already own it.
tests/conftest.py:73: in stack
1 warning, 11 errors in 152.59s
```
Evidence: `docs/agents/qa/B00/logs/06-pytest-integration-b00.log` (first run), `06b-pytest-integration-b00-rerun1.log` (retry visible in captured DEBUG log).
Deterministic reproduction without load: point the fixture at a LocalStack whose first reply is delayed beyond `read_timeout` (e.g. `docker pause` the container for 11 s right after `Ready.`).

## Fix options (pick one; the Verifier does not fix)
- Make bucket creation idempotent in the fixture: catch `s3.exceptions.BucketAlreadyOwnedByYou` or `head_bucket` first, the way `infra/scripts/s3-init.sh` `create()` already does ("create the bucket unless it already exists").
- Or create the buckets with a dedicated client that has a longer `read_timeout` (e.g. 60 s) for fixture setup only.
