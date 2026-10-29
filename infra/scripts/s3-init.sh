#!/bin/sh
# Create the three object-storage buckets with production-like semantics; safe to run repeatedly.
# Serves: D-008 (local S3 stand-in with versioning + object lock), D-007 (public pages bucket),
#   CLAUDE.md §6 (evidence written once; ID documents never public).
# Callers: the one-shot `s3-init` service in infra/docker-compose.yml (runs in the amazon/aws-cli image).
# Env: AWS_ENDPOINT_URL, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION.
set -eu

# create <bucket> [extra create-bucket args]: create the bucket unless it already exists.
create() {
  bucket=$1
  shift
  if aws s3api head-bucket --bucket "$bucket" >/dev/null 2>&1; then
    echo "s3-init: $bucket exists"
  else
    aws s3api create-bucket --bucket "$bucket" \
      --create-bucket-configuration "LocationConstraint=$AWS_DEFAULT_REGION" "$@" >/dev/null
    echo "s3-init: created $bucket"
  fi
}

# DECISION D-008: evidence photos are immutable; object lock can only be switched on when the bucket
#   is created, and it needs versioning.
#   ADV: the same write-once guarantee as S3 Object Lock, testable on a laptop.
#   COMPROMISE: GOVERNANCE mode with 1-day retention in dev (an admin can bypass it); production uses
#   S3 Object Lock with the retention set by the infra review. The local emulator is not AWS itself.
create evidence --object-lock-enabled-for-bucket
aws s3api put-bucket-versioning --bucket evidence --versioning-configuration Status=Enabled
aws s3api put-object-lock-configuration --bucket evidence --object-lock-configuration \
  '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"GOVERNANCE","Days":1}}}'

# Public batch pages: anonymous read, versioned so a rebuilt page never loses the previous one.
create public-pages
aws s3api put-bucket-versioning --bucket public-pages --versioning-configuration Status=Enabled
aws s3api put-bucket-policy --bucket public-pages --policy \
  '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::public-pages/*"}]}'

# Farmer ID documents: private, reachable only through presigned URLs issued by the API.
create id-docs
aws s3api put-public-access-block --bucket id-docs --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "s3-init: buckets evidence, public-pages, id-docs ready"
