#!/usr/bin/env bash
# run-inferno.sh — check a server GENERATED FROM US Core 8.0.0 with ONC's Inferno US Core test kit.
#
# Prerequisite (once): your user can talk to Docker:  sudo usermod -aG docker $USER  (then re-login).
#
# What it does:
#   1. clones inferno-framework/us-core-test-kit at KIT_VERSION (v1.2.0 tests US Core <= 8.0.0) and
#      runs its ./setup.sh
#   2. starts `raco fhir serve-ig hl7.fhir.us.core-8.0.0.tgz --bearer $TOKEN` on PORT (examples loaded)
#   3. starts the kit (docker compose, background) and points it at that server through the Docker host
#   4. prints how to run group 4 ("US Core FHIR API"): the web UI, and the execution script
#      us_core_server_800_fhir_tools.yaml (URL + token filled in)
# Record the outcome in inferno-us-core.md.
set -euo pipefail
KIT_VERSION="${KIT_VERSION:-v1.2.0}"
KIT_DIR="${KIT_DIR:-$HOME/.cache/fhir-tools/us-core-test-kit-$KIT_VERSION}"
PORT="${PORT:-8080}"
TOKEN="${TOKEN:-fhir-tools-inferno}"
HERE="$(cd "$(dirname "$0")" && pwd)"
SERVER_URL="http://host.docker.internal:$PORT"

docker info >/dev/null 2>&1 || { echo "Docker is not reachable for $USER (see the prerequisite above)." >&2; exit 1; }

if [ ! -d "$KIT_DIR" ]; then
  git clone --depth 1 --branch "$KIT_VERSION" https://github.com/inferno-framework/us-core-test-kit.git "$KIT_DIR"
  (cd "$KIT_DIR" && ./setup.sh)
fi

echo "== starting the US Core 8.0.0 server on :$PORT"
raco fhir serve-ig hl7.fhir.us.core-8.0.0.tgz --port "$PORT" --bearer "$TOKEN" > "$HERE/serve-ig.log" 2>&1 &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null || true' EXIT
for _ in $(seq 1 120); do curl -sf "http://localhost:$PORT/metadata" >/dev/null && break; sleep 1; done
curl -sf "http://localhost:$PORT/metadata" >/dev/null || { echo "server did not start; see $HERE/serve-ig.log" >&2; exit 1; }

echo "== starting the test kit (docker compose, background)"
(cd "$KIT_DIR" && docker compose -f docker-compose.background.yml up -d)

sed -e "s|FHIR_TOOLS_URL|$SERVER_URL|" -e "s|FHIR_TOOLS_TOKEN|$TOKEN|" \
    "$HERE/us_core_server_800_fhir_tools.yaml" > "$KIT_DIR/fhir_tools_us_core_800.yaml"

cat <<MSG

Inferno is up: open http://localhost and choose "US Core v8.0.0", then group 4 "US Core FHIR API":
  FHIR Endpoint     $SERVER_URL      (containers reach the host through host.docker.internal;
                                      on Linux the kit's compose file may need
                                      extra_hosts: ["host.docker.internal:host-gateway"])
  Access token      $TOKEN
  Patient IDs       child-example,deceased-example,example,infant-example
Headless alternative (inferno-core execution scripts; verify the command against the kit's docs):
  $KIT_DIR/fhir_tools_us_core_800.yaml
The server keeps running until you press Enter.
MSG
read -r _
