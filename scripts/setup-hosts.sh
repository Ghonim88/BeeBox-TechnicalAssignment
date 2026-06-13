#!/usr/bin/env bash
# Adds the load balancer hostname to /etc/hosts so it resolves to localhost.
# Idempotent: does nothing if an entry already exists. Requires sudo.
set -euo pipefail

HOSTNAME_ENTRY="${LB_HOSTNAME:-ucpe.swisscom.com}"
IP="127.0.0.1"
LINE="${IP} ${HOSTNAME_ENTRY}"

if grep -qE "^[^#]*[[:space:]]${HOSTNAME_ENTRY}([[:space:]]|$)" /etc/hosts; then
  echo "/etc/hosts already has an entry for ${HOSTNAME_ENTRY}; nothing to do."
  exit 0
fi

echo "Adding '${LINE}' to /etc/hosts (sudo required)..."
echo "${LINE}" | sudo tee -a /etc/hosts >/dev/null
echo "Done."
