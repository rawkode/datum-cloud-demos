#!/usr/bin/env bash
#
# Live-demo driver for "Deploy a workload to Datum Compute".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_PROJECT   project id                                   (required)
#   DEMO_IMAGE     fully qualified image serving HTTP           (required)
#   DEMO_NAME      workload name                                (default: hello)
#   DEMO_CITY      first city code                              (default: DFW)
#   DEMO_CITY2     second city code for the spread beat         (default: IAD; empty to skip)
#   DEMO_PORT      HTTP port the container listens on           (default: 8080)
#   DEMO_OPEN      set to 1 to open the published URL in a browser after deploy
#   DEMO_MANIFEST  manifest for the closing beat                (default: manifests/hello.yaml)
#   DEMO_DESTROY   set to 0 to leave the workload running at the end
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_PROJECT:?set DEMO_PROJECT}"
: "${DEMO_IMAGE:?set DEMO_IMAGE}"
DEMO_NAME="${DEMO_NAME:-hello}"
DEMO_CITY="${DEMO_CITY:-DFW}"
DEMO_CITY2="${DEMO_CITY2-IAD}"
DEMO_PORT="${DEMO_PORT:-8080}"
DEMO_MANIFEST="${DEMO_MANIFEST:-$(dirname "$0")/manifests/hello.yaml}"
DEMO_DESTROY="${DEMO_DESTROY:-1}"
export DATUM_PROJECT="$DEMO_PROJECT"

DEPLOY="datumctl compute deploy ${DEMO_NAME} --image=${DEMO_IMAGE} --city=${DEMO_CITY} --http-port=${DEMO_PORT}"

clear

note "Cold open: the whole video in one line"
printf '%s$ %s%s%s\n' "$green" "$reset$bold" "$DEPLOY" "$reset"
pause; clear

note "Beat 1: install the plugin, check access and quota"
run "datumctl plugin search compute"
run "datumctl plugin install compute"
run "datumctl compute --help"
run "datumctl compute access"
run "datumctl compute quota"
pause; clear

note "Beat 2: deploy with flags"
run "$DEPLOY"
if [[ "${DEMO_OPEN:-0}" == "1" ]]; then
  url="$(datumctl compute workloads -o json 2>/dev/null | jq -r --arg n "$DEMO_NAME" '.[] | select(.name==$n) | .url // empty' || true)"
  if [[ -n "$url" ]]; then
    note "Opening ${url}"
    open "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null || true
    pause
  fi
fi
pause; clear

note "Beat 3: inspect what is running"
run "datumctl compute workloads"
run "datumctl compute workloads describe ${DEMO_NAME}"
run "datumctl compute instances --workload=${DEMO_NAME}"
pause; clear

note "Beat 4: scale and spread"
run "datumctl compute scale ${DEMO_NAME} --min=2"
run "datumctl compute rollout ${DEMO_NAME}"
if [[ -n "$DEMO_CITY2" ]]; then
  run "datumctl compute deploy ${DEMO_NAME} --image=${DEMO_IMAGE} --city=${DEMO_CITY},${DEMO_CITY2} --http-port=${DEMO_PORT}"
  run "datumctl compute workloads describe ${DEMO_NAME}"
fi
pause; clear

note "Closing: graduate to a manifest"
run "datumctl get workloads"
run "datumctl get workload ${DEMO_NAME} -o yaml"
run "cat ${DEMO_MANIFEST}"
run "datumctl compute deploy -f ${DEMO_MANIFEST}"
if [[ "$DEMO_DESTROY" == "1" ]]; then
  run "datumctl compute destroy ${DEMO_NAME}"
fi
pause; clear

note "Recap"
cat <<'RECAP'
  datumctl plugin install compute
  datumctl compute deploy <name> --image=… --city=… --http-port=…
  datumctl compute workloads describe <name>
  datumctl compute scale <name> --min=N
  datumctl compute deploy -f workload.yaml

  One image, one command, running at the edge.
RECAP
printf '\n'
