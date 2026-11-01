#!/bin/zsh
# Verifier scratch: wipe and reseed the isolated QA stack on the current-main image; admin gets the super-admin flag.
cd /Users/fi-it/Documents/projects/agriGitag
export API_PORT=8010 DB_PORT=5443 REDIS_PORT=6389 S3_PORT=4576 MQTT_PORT=1893
qc() { docker compose -p agritrace-p07qa -f infra/docker-compose.yml -f /private/tmp/claude-501/-Users-fi-it-Documents-projects-agriGitag/1234289e-8332-4673-8beb-a187a8f85a38/scratchpad/compose-qa-image.yml "$@"; }
date -u +%FT%TZ; git log -1 --format='HEAD %h'
qc down -v && qc up -d --wait --no-build && qc exec -T api sh -c "alembic upgrade head && python -m agritrace.seed.demo"
echo "exit=$?"
docker exec agritrace-p07qa-db-1 psql -U agritrace -d agritrace -c "update users set is_super_admin=true where phone='+919000000001'"
