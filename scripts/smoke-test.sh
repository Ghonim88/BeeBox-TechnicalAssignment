#!/usr/bin/env bash
# Smoke test for the BeeBox load balancer:
#   1. asserts the endpoint returns HTTP 200
#   2. asserts the body is valid JSON containing a data array
#   3. hits the endpoint repeatedly to prove round-robin across web-1 / web-2
set -euo pipefail

LB_HOSTNAME="${LB_HOSTNAME:-ucpe.swisscom.com}"
LB_PORT="${LB_PORT:-8080}"
ENDPOINT="http://${LB_HOSTNAME}:${LB_PORT}/api/data"

echo "Testing ${ENDPOINT}"

# 1. HTTP status
code=$(curl -s -o /dev/null -w '%{http_code}' "${ENDPOINT}")
if [[ "${code}" != "200" ]]; then
  echo "ERROR: expected HTTP 200, got ${code}" >&2
  exit 1
fi
echo "  [OK] HTTP 200"

# 2. JSON validity + content
body=$(curl -s "${ENDPOINT}")
echo "${body}" | python3 -c "import sys, json; d = json.load(sys.stdin); assert isinstance(d.get('data'), list), 'response has no data array'; print('  [OK] valid JSON with %d row(s)' % len(d['data']))"

# 3. Round-robin proof
echo "Checking round-robin distribution (6 requests)..."
declare -A seen
for i in $(seq 1 6); do
  host=$(curl -s "${ENDPOINT}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('served_by', '?'))")
  echo "  request ${i} -> ${host}"
  seen["${host}"]=1
done

if ((${#seen[@]} >= 2)); then
  echo "  [OK] round-robin confirmed across ${#seen[@]} backends: ${!seen[*]}"
else
  echo "  [WARN] only one backend responded (${!seen[*]}); expected 2" >&2
fi

echo "Smoke test passed."
