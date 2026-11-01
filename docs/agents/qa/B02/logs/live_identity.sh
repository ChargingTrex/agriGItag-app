#!/usr/bin/env bash
# Verifier live check of B02 acceptance lines on the compose stack (http://localhost:8000, ENV=dev, OTP_DEV_CODE=123456).
set -u
API=http://localhost:8000/v1
F1=+919000000013   # seeded farmer, main flow
F2=+919000000012   # seeded farmer, lock test
DEV=$(uuidgen | tr A-Z a-z)
c() { echo "\$ curl $*"; curl -s -w '\n-> HTTP %{http_code}\n' "$@"; echo; }
echo "== 1. OTP request 2x in 60 s -> 429"
c -X POST $API/auth/otp/request -H 'Content-Type: application/json' -d "{\"phone\":\"$F1\"}"
c -X POST $API/auth/otp/request -H 'Content-Type: application/json' -d "{\"phone\":\"$F1\"}"
echo "== sign in farmer with dev code (device $DEV)"
S=$(curl -s -X POST $API/auth/otp/verify -H 'Content-Type: application/json' -d "{\"phone\":\"$F1\",\"code\":\"123456\",\"device_id\":\"$DEV\",\"platform\":\"android\"}")
echo "$S" | python3 -c 'import json,sys; d=json.load(sys.stdin); print({k:(v[:12]+"..." if k.endswith("token") else v) for k,v in d.items()})'
AT=$(echo "$S" | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')
RT=$(echo "$S" | python3 -c 'import json,sys; print(json.load(sys.stdin)["refresh_token"])')
echo "== 3. farmer on GET /flags -> 403 (real B08 route)"
c $API/flags -H "Authorization: Bearer $AT"
echo "== 6. logout revokes refresh -> 401"
c -X POST $API/auth/logout -H "Authorization: Bearer $AT"
c -X POST $API/auth/refresh -H 'Content-Type: application/json' -d "{\"refresh_token\":\"$RT\"}"
c $API/me -H "Authorization: Bearer $AT"
echo "== 2. 5 wrong codes -> 409 otp_locked (farmer $F2)"
c -X POST $API/auth/otp/request -H 'Content-Type: application/json' -d "{\"phone\":\"$F2\"}"
for i in 1 2 3 4 5; do c -X POST $API/auth/otp/verify -H 'Content-Type: application/json' -d "{\"phone\":\"$F2\",\"code\":\"000000\",\"device_id\":\"$DEV\",\"platform\":\"android\"}"; done
echo "== right code after lock is still refused"
c -X POST $API/auth/otp/verify -H 'Content-Type: application/json' -d "{\"phone\":\"$F2\",\"code\":\"123456\",\"device_id\":\"$DEV\",\"platform\":\"android\"}"
