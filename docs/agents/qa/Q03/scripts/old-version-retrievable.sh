#!/usr/bin/env bash
# Q03 step 3 / FR-17: rebuild a published batch through the API, then show that S3 keeps both object versions
# and the older one is still fetchable with ?versionId=. Serves: PLAN §7.5 Q03, D-034 (rebuild keeps old versions).
# Caller: the Q03 Verifier, once. Input: $ADMIN_TOKEN (FPO admin access token, never printed), batch id and code.
set -u
ID=${1:?batch id}; CODE=${2:?batch code}; API=http://localhost:8000/v1; S3=http://localhost:4566/public-pages
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=ap-south-1
V() { aws --endpoint-url http://localhost:4566 s3api list-object-versions --bucket public-pages --prefix "batches/$CODE/" \
      --query 'Versions[].[Key,VersionId,IsLatest,LastModified,Size]' --output text; }
date; echo "## versions before"; V
echo "\$ POST $API/batches/$ID/rebuild"; curl -s -w '\n-> HTTP %{http_code}\n' -X POST -H "Authorization: Bearer $ADMIN_TOKEN" "$API/batches/$ID/rebuild"
for i in $(seq 1 60); do
  s=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$API/batches/$ID/builds" | python3 -c 'import json,sys; i=json.load(sys.stdin)["items"]; b=max(i,key=lambda x:x["build_no"]); print(b["build_no"], b["status"], (b.get("error") or {}).get("code"))')
  case "$s" in *queued*|*running*) sleep 3;; *) break;; esac
done; echo "latest build: $s (after ~$((i*3)) s)"
echo "## versions after"; V
OLD=$(aws --endpoint-url http://localhost:4566 s3api list-object-versions --bucket public-pages --prefix "batches/$CODE/index.html" \
      --query 'Versions[?IsLatest==`false`]|[0].VersionId' --output text)
NEW=$(aws --endpoint-url http://localhost:4566 s3api list-object-versions --bucket public-pages --prefix "batches/$CODE/index.html" \
      --query 'Versions[?IsLatest==`true`]|[0].VersionId' --output text)
for v in "$OLD" "$NEW"; do
  curl -s -o /tmp/q03-v.html -w "GET $S3/batches/$CODE/index.html?versionId=$v -> %{http_code} %{size_download} B\n" "$S3/batches/$CODE/index.html?versionId=$v"
  echo "  generation in page: $(grep -o 'generation[^<]\{0,40\}' /tmp/q03-v.html | head -1)  sha256: $(shasum -a 256 /tmp/q03-v.html | cut -c1-16)"
done
for v in $(aws --endpoint-url http://localhost:4566 s3api list-object-versions --bucket public-pages --prefix "batches/$CODE/data.json" --query 'Versions[].VersionId' --output text); do
  curl -s "$S3/batches/$CODE/data.json?versionId=$v" | python3 -c "import json,sys; d=json.load(sys.stdin); print('data.json versionId=$v footer.generation =', d['footer'].get('generation'))"
done
echo "\$ GET $S3/batches/$CODE/index.html (no versionId) -> latest:"; curl -s -o /dev/null -w '%{http_code} %{size_download} B\n' "$S3/batches/$CODE/index.html"
date
