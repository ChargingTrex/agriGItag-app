#!/bin/sh
# Create the three object-storage buckets with production-like semantics; safe to run repeatedly.
# Serves: D-008 (MinIO as S3 stand-in with versioning + object lock), D-007 (public pages bucket),
#   CLAUDE.md §6 (evidence written once; ID documents never public).
# Callers: the one-shot `minio-init` service in infra/docker-compose.yml (runs in the mc client image).
# Env: S3_ENDPOINT, MINIO_ROOT_USER, MINIO_ROOT_PASSWORD.
set -eu

until mc alias set local "$S3_ENDPOINT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" >/dev/null 2>&1; do
  echo "minio-init: waiting for $S3_ENDPOINT"
  sleep 1
done

# DECISION D-008: evidence photos are immutable; object lock can only be switched on when the bucket
#   is created, and it implies versioning.
#   ADV: the same write-once guarantee as S3 Object Lock, testable on a laptop.
#   COMPROMISE: GOVERNANCE mode with 1-day retention in dev (an admin can bypass it); production uses
#   S3 Object Lock with the retention set by the infra review.
mc mb --ignore-existing --with-lock local/evidence
mc version enable local/evidence
mc retention set --default GOVERNANCE 1d local/evidence

# Public batch pages: anonymous read, versioned so a rebuilt page never loses the previous one.
mc mb --ignore-existing local/public-pages
mc version enable local/public-pages
mc anonymous set download local/public-pages

# Farmer ID documents: private, reachable only through presigned URLs issued by the API.
mc mb --ignore-existing local/id-docs
mc anonymous set none local/id-docs

echo "minio-init: buckets evidence, public-pages, id-docs ready"
