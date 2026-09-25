#!/usr/bin/env bash
#
# Live-demo driver for "Add cloud commands with plugins".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_ORG       organisation id                     (required)
#   DEMO_PROJECT   project id                          (required)
#   DEMO_ZONE      domain to create in Beat 3          (default: example-demo.com)
#   DEMO_CLEANUP   set to 1 to delete the zone and remove the plugin at the end
#   DEMO_TYPE_MS   per-character typing delay in ms   (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_ORG:?set DEMO_ORG}"
: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_ZONE="${DEMO_ZONE:-rawkode.xyz}"
CTX="${DEMO_ORG}/${DEMO_PROJECT}"

# Make sure the plugin is absent so the cold open and install are real.
datumctl plugin remove dns >/dev/null 2>&1 || true
datumctl ctx use "$CTX" >/dev/null 2>&1 || true

clear

note "Cold open: ask for a command that isn't there yet  (answer N)"
run "datumctl dns"
pause; clear

note "Beat 1: find plugins  (kubectl krew search)"
run "datumctl plugin search"
run "datumctl plugin search dns"
pause; clear

note "Beat 2: install and check  (kubectl krew install / list)"
run "datumctl plugin install dns"
run "datumctl plugin list"
run "datumctl dns version"
run "datumctl dns --help"
note "Try tab completion by hand:  datumctl dns zone <TAB>"
pause; clear

note "Beat 3: use the DNS plugin  (context and credentials are inherited)"
run "datumctl whoami"
run "datumctl dns zone list"
run "datumctl dns zone create ${DEMO_ZONE}"
run "datumctl dns record create ${DEMO_ZONE} www A 203.0.113.10"
run "datumctl dns record create ${DEMO_ZONE} @ TXT \"v=spf1 -all\""
run "datumctl dns record list ${DEMO_ZONE}"
run "datumctl dns zone describe ${DEMO_ZONE}"
run "datumctl dns zone nameservers ${DEMO_ZONE} --check"
run "datumctl dns zone list -o json | head -20"
pause; clear

note "Beat 4: keep plugins current  (kubectl krew upgrade / uninstall)"
run "datumctl plugin upgrade dns"
run "datumctl plugin install"
run "datumctl plugin index list"
if [[ "${DEMO_CLEANUP:-0}" == "1" ]]; then
  run "datumctl dns zone delete ${DEMO_ZONE} --yes"
  run "datumctl plugin remove dns"
fi
pause; clear

note "Recap"
cat <<'RECAP'
  datumctl plugin search
  datumctl plugin install dns
  datumctl plugin list
  datumctl dns zone list
  datumctl plugin upgrade dns

  The core CLI stays small. The services you use grow it.
RECAP
printf '\n'
