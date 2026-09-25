#!/usr/bin/env bash
#
# Live-demo driver for "Find out what changed".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_PROJECT   project id                                   (required)
#   DEMO_ZONE      an existing DNSZone name in the project      (required for seeding)
#   DEMO_RECORD    DNSRecordSet name to investigate             (default: www-a)
#   DEMO_ACTOR     username to filter on in the audit beat      (default: discovered via --suggest)
#   DEMO_WINDOW    relative start time for queries              (default: now-1h)
#   DEMO_SEED      set to 1 to create the record and apply the "bad" change, then exit
#   DEMO_WATCH     set to 1 to run the closing --watch beat (you must Ctrl-C out of it)
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_RECORD="${DEMO_RECORD:-www-a}"
DEMO_WINDOW="${DEMO_WINDOW:-now-1h}"
GOOD_IP="${GOOD_IP:-203.0.113.10}"
BAD_IP="${BAD_IP:-198.51.100.7}"

# ---------------------------------------------------------------------------
# Seed: create the record with a good address, then apply the "bad" change.
# Run this before recording, ideally as a different user than you record with.
# ---------------------------------------------------------------------------
record_manifest() {
  cat <<YAML
apiVersion: dns.networking.miloapis.com/v1alpha1
kind: DNSRecordSet
metadata:
  name: ${DEMO_RECORD}
  namespace: default
spec:
  dnsZoneRef:
    name: ${DEMO_ZONE}
  recordType: A
  records:
    - name: www
      ttl: 300
      a:
        content: "$1"
YAML
}

if [[ "${DEMO_SEED:-0}" == "1" ]]; then
  : "${DEMO_ZONE:?set DEMO_ZONE to an existing DNSZone name for seeding}"
  echo >&2 "Seeding: create ${DEMO_RECORD} -> ${GOOD_IP}"
  record_manifest "$GOOD_IP" | datumctl apply --project "$DEMO_PROJECT" -f -
  echo >&2 "Waiting 20s so the two versions are distinguishable in history"
  sleep 20
  echo >&2 "Seeding: the incident. ${DEMO_RECORD} -> ${BAD_IP}"
  record_manifest "$BAD_IP" | datumctl apply --project "$DEMO_PROJECT" -f -
  echo >&2 "Seeded. Give the activity service a minute to index, then run without DEMO_SEED."
  exit 0
fi

clear

note "Cold open: www is pointing at the wrong box. Who touched it?"
run "datumctl get dnsrecordset ${DEMO_RECORD} --project ${DEMO_PROJECT} -o jsonpath='{.spec.records[*].a.content}'; echo"
pause; clear

note "Beat 1: start wide with the feed"
run "datumctl activity feed --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW}"
run "datumctl activity feed --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --change-source human"
run "datumctl activity feed --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --change-source human --kind DNSRecordSet"
pause; clear

note "Beat 2: what exactly changed"
run "datumctl activity history dnsrecordsets ${DEMO_RECORD} --project ${DEMO_PROJECT}"
run "datumctl activity history dnsrecordsets ${DEMO_RECORD} --project ${DEMO_PROJECT} --diff"
pause; clear

note "Beat 3: who did it, and from where"
run "datumctl activity audit --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --resource dnsrecordsets --verb update"
run "datumctl activity audit --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --suggest user.username"

actor="${DEMO_ACTOR:-}"
if [[ -z "$actor" ]]; then
  # Best effort: take the user on the most recent update to the record.
  actor="$(datumctl activity audit --project "$DEMO_PROJECT" --start-time "$DEMO_WINDOW" \
    --resource dnsrecordsets --verb update --limit 1 \
    -o jsonpath='{.items[0].user.username}' 2>/dev/null || true)"
fi
if [[ -n "$actor" ]]; then
  run "datumctl activity audit --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --user ${actor}"
else
  note "(could not determine actor; set DEMO_ACTOR to run the --user beat)"
fi

run "datumctl activity audit --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --filter='verb == \"update\" && objectRef.resource == \"dnsrecordsets\"' -o jsonpath='{range .items[*]}{.requestReceivedTimestamp}{\"\\t\"}{.user.username}{\"\\t\"}{.userAgent}{\"\\n\"}{end}'"
pause; clear

note "Beat 4: what the platform did about it"
run "datumctl activity events --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --regarding-kind DNSRecordSet --regarding-name ${DEMO_RECORD}"
run "datumctl activity events --project ${DEMO_PROJECT} --start-time ${DEMO_WINDOW} --type Warning"
pause; clear

note "Closing: keep the record"
run "datumctl activity audit --project ${DEMO_PROJECT} --start-time now-24h --all-pages -o json > incident-\$(date +%F).json; ls -la incident-*.json"
if [[ "${DEMO_WATCH:-0}" == "1" ]]; then
  note "Closing: keep watching (Ctrl-C to stop the stream)"
  run "datumctl activity feed --project ${DEMO_PROJECT} --change-source human --watch"
fi
pause; clear

note "Recap"
cat <<'RECAP'
  datumctl activity feed --change-source human
  datumctl activity history <type> <name> --diff
  datumctl activity audit --user <who>
  datumctl activity events --regarding-name <name>

  What changed, who changed it, when, and what happened next.
RECAP
printf '\n'
