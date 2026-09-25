#!/usr/bin/env bash
#
# Live-demo driver for "Use the Datum API without handling tokens".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail (the proxy is killed on exit).
#
# Run the proxy in a SECOND pane yourself for the on-camera beats; this script
# starts its own background proxy only where a beat needs one it controls.
#
# Configure with env vars (see README.md):
#   DEMO_PROJECT   project id                                     (required)
#   DEMO_PORT      proxy port                                     (default: 8001)
#   DEMO_DNS_PATH  project-scoped path to list DNS zones           (default: apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones)
#   DEMO_MANAGED   set to 1 to also start the proxy from this script instead of a second pane
#   DEMO_LOGOUT    set to 1 to run the closing logout/login beat
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_PORT="${DEMO_PORT:-8001}"
DEMO_DNS_PATH="${DEMO_DNS_PATH:-apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones}"
PROXY="http://127.0.0.1:${DEMO_PORT}"
PLATFORM="apis/resourcemanager.miloapis.com/v1alpha1"

proxy_pid=""
start_proxy() {  # start_proxy [extra flags...]
  stop_proxy
  datumctl api proxy --port "$DEMO_PORT" "$@" >/dev/null 2>&1 &
  proxy_pid=$!
  sleep 1
}
stop_proxy() { [[ -n "$proxy_pid" ]] && kill "$proxy_pid" 2>/dev/null || true; proxy_pid=""; }
trap stop_proxy EXIT

clear

note "Cold open: the way everyone does it first"
run "TOKEN=\$(datumctl auth get-token); curl -s -H \"Authorization: Bearer \$TOKEN\" https://api.datum.net/${PLATFORM}/organizations | jq '.items[].metadata.name'"
pause; clear

note "Beat 1: start the proxy (left pane: datumctl api proxy --port ${DEMO_PORT})"
if [[ "${DEMO_MANAGED:-0}" == "1" ]]; then start_proxy; else pause; fi
run "curl -s ${PROXY}/${PLATFORM}/organizations | jq '.items[].metadata.name'"
run "curl -s -H 'Authorization: Bearer this-is-ignored' ${PROXY}/${PLATFORM}/organizations | jq '.items | length'"
pause; clear

note "Beat 2: the API has the shape you expect"
run "curl -s ${PROXY}/apis | jq '.groups[].name'"
run "curl -s ${PROXY}/${PLATFORM}/projects/${DEMO_PROJECT}/control-plane/apis | jq '.groups[].name'"
run "curl -s ${PROXY}/${PLATFORM}/projects/${DEMO_PROJECT}/control-plane/${DEMO_DNS_PATH} | jq '.items[].metadata.name'"
pause; clear

note "Beat 3: scope the proxy to a project (left pane: datumctl api proxy --port ${DEMO_PORT} --project ${DEMO_PROJECT})"
if [[ "${DEMO_MANAGED:-0}" == "1" ]]; then start_proxy --project "$DEMO_PROJECT"; else pause; fi
run "curl -s ${PROXY}/${DEMO_DNS_PATH} | jq '.items[].metadata.name'"
run "datumctl get dnszones --project ${DEMO_PROJECT} -o json | jq '.items[].metadata.name'"
note "Watch streams straight through. Ctrl-C to stop."
run "curl -sN \"${PROXY}/${DEMO_DNS_PATH}?watch=true\" | head -c 600"
pause; clear

note "Beat 4: use it from code"
cat > /tmp/datum-proxy-demo.py <<PY
import json, urllib.request

PROXY = "${PROXY}"
url = f"{PROXY}/${DEMO_DNS_PATH}"
with urllib.request.urlopen(url) as r:
    for z in json.load(r)["items"]:
        print(z["metadata"]["name"])
PY
run "cat /tmp/datum-proxy-demo.py"
run "python3 /tmp/datum-proxy-demo.py"
note "Fully script-managed: random port, URL on stdout line 1"
run "datumctl api proxy --quiet --project ${DEMO_PROJECT} > /tmp/proxy.url & PID=\$!; sleep 1; URL=\$(head -n1 /tmp/proxy.url); echo \"proxy at \$URL\"; curl -s \"\$URL/${DEMO_DNS_PATH}\" | jq '.items | length'; kill \$PID"
pause; clear

if [[ "${DEMO_LOGOUT:-0}" == "1" ]]; then
  note "Closing: the proxy survives a logout/login"
  run "datumctl logout"
  run "curl -s -o /dev/null -w '%{http_code}\n' ${PROXY}/apis"
  run "datumctl login"
  run "curl -s -o /dev/null -w '%{http_code}\n' ${PROXY}/apis"
  pause; clear
fi

note "Recap"
cat <<'RECAP'
  datumctl api proxy --port 8001 --project <project>
  curl http://127.0.0.1:8001/apis/<group>/<version>/<resource>

  No tokens in your script. Ever.
RECAP
printf '\n'
