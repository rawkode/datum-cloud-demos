#!/usr/bin/env bash
#
# Live-demo driver for "Make safe changes to Datum".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_PROJECT   project id                                   (required)
#   DEMO_DOMAIN    domain for the demo zone (default: example.com)
#   DEMO_DRIFT     set to 1 to run the optional out-of-band edit + drift beat
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)
#
# The manifests in ./manifests and ./mistakes are rendered into a scratch
# directory with DEMO_DOMAIN substituted, and the demo runs from there, so the
# on-screen paths read as manifests/... and the source files are never edited.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_DOMAIN="${DEMO_DOMAIN:-example.com}"
export DATUM_PROJECT="$DEMO_PROJECT"

# Render manifests into a scratch dir and work from there.
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d)"
for d in manifests mistakes; do
  mkdir -p "$work/$d"
  for f in "$src/$d"/*.yaml; do
    sed "s/example\.com/${DEMO_DOMAIN}/g" "$f" > "$work/$d/$(basename "$f")"
  done
done
cd "$work"
cleanup() { cd /; rm -rf "$work"; }
trap cleanup EXIT

clear

note "Cold open: the command with no confirmation prompt"
cmd="datumctl delete dnszone production"
printf '%s$ %s' "$green" "$reset"; type_out "${bold}${cmd}${reset}"
pause
# Enter echoed a newline; go back up and put ^C at the end of the typed command.
printf '\033[1A\033[%dG  %s^C%s\n' "$(( ${#cmd} + 3 ))" "$dim" "$reset"
pause; clear

note "Step 1: inspect the schema before you write"
run "datumctl explain dnszones"
run "datumctl explain dnszones.spec"
run "datumctl get dnszoneclasses"
run "datumctl explain dnsrecordsets.spec.records"
pause; clear

note "Step 2: preview  (what would change, and would the server accept it)"
run "cat manifests/dnszone.yaml"
run "cat manifests/records.yaml"
run "datumctl diff -f manifests/; echo \"exit: \$?\""
run "datumctl apply -f manifests/ --dry-run=server"
note "Catching a mistake before it ships"
run "cat mistakes/dnszone-typo.yaml"
run "datumctl apply -f mistakes/dnszone-typo.yaml --dry-run=server"
pause; clear

note "Step 3: apply, then verify"
run "datumctl apply -f manifests/"
run "datumctl get dnszones,dnsrecordsets -l demo=safe-changes"
run "datumctl describe dnszone safe-changes-demo"
run "datumctl describe dnsrecordset safe-changes-demo-www"
pause; clear

note "Step 4: change something and do it all again"
run "sed -i '' 's/203.0.113.10/203.0.113.20/' manifests/records.yaml"
run "datumctl diff -f manifests/; echo \"exit: \$?\""
run "datumctl apply -f manifests/ --dry-run=server && datumctl apply -f manifests/"
run "datumctl describe dnsrecordset safe-changes-demo-www"

if [[ "${DEMO_DRIFT:-0}" == "1" ]]; then
  note "Optional: detect drift from an out-of-band change"
  run "datumctl edit dnsrecordset safe-changes-demo-www"
  run "datumctl diff -f manifests/; echo \"exit: \$?\""
  run "datumctl apply -f manifests/"
  run "datumctl diff -f manifests/; echo \"exit: \$?\""
fi
pause; clear

note "Closing: clean up, safely"
run "datumctl delete -f manifests/ --dry-run=client"
run "datumctl delete -f manifests/"
run "datumctl get dnszones -l demo=safe-changes"
pause; clear

note "Recap"
cat <<'RECAP'
  datumctl explain <type>.spec
  datumctl diff -f ./manifests/
  datumctl apply -f ./manifests/ --dry-run=server
  datumctl apply -f ./manifests/
  datumctl describe <type> <name>

  Inspect, preview, apply, verify. Nothing on Datum should surprise you.
RECAP
printf '\n'
