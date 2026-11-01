#!/bin/sh
# B20 evidence for QA issue B08-2: grep the compose api/worker/db logs from the start of the 20-run reproduction
# (live_b20_deadlock.py, started 2026-11-01T18:59:25Z) for deadlocks, HTTP 500s and the concurrent rules tasks.
# Caller: B20 Worker; output saved as 02-log-greps.txt. Usage: sh greps.sh [since]
SINCE=${1:-2026-11-01T18:59:20Z}
UNTIL=2026-11-01T19:02:00Z
for c in agritrace-api-1 agritrace-worker-1 agritrace-db-1; do
  echo "$c 'deadlock' lines: $(docker logs --since "$SINCE" --until "$UNTIL" "$c" 2>&1 | grep -ci deadlock)"
done
echo "agritrace-api-1 HTTP 500 lines: $(docker logs --since "$SINCE" --until "$UNTIL" agritrace-api-1 2>&1 | grep -c ' 500 ')"
echo "agritrace-api-1 POST /v1/intakes 201 lines: $(docker logs --since "$SINCE" --until "$UNTIL" agritrace-api-1 2>&1 | grep -c 'POST /v1/intakes HTTP/1.1\" 201')"
echo "agritrace-worker-1 rules.check_event lines: $(docker logs --since "$SINCE" --until "$UNTIL" agritrace-worker-1 2>&1 | grep -c check_event)"
echo
echo "## concurrency sample (first runs): check_event received/succeeded vs push/intake answers, by time"
{
  docker logs -t --since "$SINCE" --until "$UNTIL" agritrace-worker-1 2>&1 | grep -E "rules.check_event.*(received|succeeded)"
  docker logs -t --since "$SINCE" --until "$UNTIL" agritrace-api-1 2>&1 | grep -E "POST /v1/(intakes|sync/push)"
} | sort | head -24
