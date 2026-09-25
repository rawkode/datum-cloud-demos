#!/usr/bin/env bash
#
# Live-demo driver for "Build a custom datumctl plugin".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_PROJECT    project id for the --project override beat        (required)
#   DEMO_ALT_PROJECT a second project id for the override beat        (optional)
#   DEMO_TYPE_MS    per-character typing delay in ms (default: 25; 0 to disable)
#
# Assumes you are logged in with an active org/project context (datumctl whoami).

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_PROJECT:?set DEMO_PROJECT}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HERE/bin"

# Start clean: no stale binary, no stale trust.
rm -rf "$BIN"
datumctl plugin untrust zones >/dev/null 2>&1 || true
cd "$HERE/plugin"

clear

note "Cold open: the command datumctl doesn't have yet"
run "datumctl zones summary"
pause; clear

note "Beat 1: the contract  (open plugin/main.go in your editor)"
run "grep -n 'go.datum.net/datumctl/plugin\|plugin\.' main.go"
pause; clear

note "Beat 2: build, run, trust"
run "go build -o ../bin/datumctl-zones ."
run "../bin/datumctl-zones --plugin-manifest"
run "../bin/datumctl-zones summary"
export PATH="$BIN:$PATH"
run "export PATH=\"\$PWD/../bin:\$PATH\""
run "datumctl zones summary"
run "datumctl plugin trust zones"
run "datumctl zones context"
pause; clear

note "Beat 3: use it like a real command"
run "datumctl zones summary"
run "datumctl zones summary -o json"
if [[ -n "${DEMO_ALT_PROJECT:-}" ]]; then
  run "datumctl zones summary --project ${DEMO_ALT_PROJECT}"
fi
run "datumctl zones summary --project does-not-exist; echo \"exit=\$?\""
note "Tab completion is forwarded to the plugin (type: datumctl zones <TAB>)"
run "datumctl __complete zones '' 2>/dev/null"
pause; clear

note "Closing: shipping it"
run "datumctl plugin list"
run "datumctl plugin install --help | head -20"
pause; clear

note "Recap"
cat <<'RECAP'
  go get go.datum.net/datumctl/plugin
  plugin.ServeManifest(m)
  plugin.NewRootCmd(name, short)
  plugin.Context()
  plugin.Token()

  Name it datumctl-<name>. Trust it locally. Release it to ship.
RECAP
printf '\n'
