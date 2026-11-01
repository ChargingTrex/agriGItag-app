#!/usr/bin/env bash
# Q03 step 1 / BM-09: download every object in s3://public-pages (LocalStack) and run the project privacy linter
# on each batch folder, with every stored phone, land-record ref and ID-document key as canaries.
# Serves: PLAN §7.5 Q03, §8 BM-09, CLAUDE.md §6. Caller: the Q03 Verifier, once. Canary values are never printed.
set -u
OUT=${1:?download dir}
ROOT=$(cd "$(dirname "$0")/../../../../.." && pwd)
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=ap-south-1 PGPASSWORD=agritrace
q() { psql -h localhost -p 5433 -U agritrace agritrace -Atc "$1"; }
uptime; date; git -C "$ROOT" rev-parse --short HEAD
echo "\$ aws --endpoint-url http://localhost:4566 s3 ls --recursive s3://public-pages/"
aws --endpoint-url http://localhost:4566 s3 ls --recursive s3://public-pages/
aws --endpoint-url http://localhost:4566 s3 sync --only-show-errors s3://public-pages/ "$OUT"
CAN=()
while IFS= read -r v; do [ -n "$v" ] && CAN+=(--canary "$v"); done < <(
  q "select phone from users union select substr(phone,4) from users where phone like '+91%'
     union select land_record_ref from plots where land_record_ref is not null and land_record_ref<>''
     union select object_key from id_documents
     union select address->>'pin' from farmers where address ? 'pin' and address->>'pin'<>''")
echo "canaries: $(( ${#CAN[@]} / 2 )) values (users.phone with and without +91, plots.land_record_ref, id_documents.object_key, farmers.address.pin)"
total=0
for d in "$OUT"/batches/*/; do
  echo "\$ python3 infra/scripts/privacy-lint.py ${d#$OUT/} --canary <${#CAN[@]} args>"
  python3 "$ROOT/infra/scripts/privacy-lint.py" "$d" "${CAN[@]}"; rc=$?; echo "exit=$rc"
  [ $rc -ne 0 ] && total=$((total+1))
done
echo "folders with hits: $total"
echo "\$ python3 infra/scripts/privacy-lint.py <all pages>"; python3 "$ROOT/infra/scripts/privacy-lint.py" "$OUT" "${CAN[@]}"; echo "exit=$?"
uptime
