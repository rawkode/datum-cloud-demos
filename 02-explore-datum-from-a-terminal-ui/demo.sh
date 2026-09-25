#!/usr/bin/env bash
#
# Live-demo driver for "Explore Datum from a terminal UI".
#
# The console is interactive, so this driver only sets the stage: it verifies
# the context, prints the keystroke plan for the presenter, then launches
# `datumctl console`. Drive the TUI by hand following SCRIPT.md.
#
# Configure with env vars (see README.md):
#   DEMO_ORG        organisation id   (required)
#   DEMO_PROJECT    project id        (required)
#   DEMO_ALT_CTX    a second context to switch to with [c], e.g. "my-org/staging" (optional)
#   DEMO_READ_ONLY  set to 0 to launch without --read-only (default: 1)
#   DEMO_TYPE_MS    per-character typing delay in ms (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_ORG:?set DEMO_ORG}"
: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_READ_ONLY="${DEMO_READ_ONLY:-1}"
CTX="${DEMO_ORG}/${DEMO_PROJECT}"

# Pre-flight (off camera): make sure the console will open on the right project.
cols=$(tput cols 2>/dev/null || echo 0); rows=$(tput lines 2>/dev/null || echo 0)
if (( cols < 120 || rows < 40 )); then
  note "Terminal is ${cols}x${rows}; the dashboard needs at least 120x40 to show every section."
fi
datumctl ctx use "${CTX}" >/dev/null
note "Context: $(datumctl whoami | sed -n 's/^Context: *//p')"
[[ -n "${DEMO_ALT_CTX:-}" ]] && note "Alt context for [c]: ${DEMO_ALT_CTX}"

note "Keystroke plan"
cat >> "$DEMO_NOTES" <<'PLAN'
  Beat 1  dashboard      ?  (open help)   ?  (close)
  Beat 2  browse         j j j  Enter (dnszones)   /  <name> Enter   Esc   z
  Beat 3  inspect        j  d   y   C   E   H  ] [   Esc Esc
  Beat 4  dashboards     3   3   4   Esc   c  <pick alt ctx> Enter   c  <pick back>
  Close                  q
PLAN
clear

note "Cold open"
if [[ "$DEMO_READ_ONLY" == "1" ]]; then
  run "datumctl console --read-only"
else
  run "datumctl console"
fi

note "Recap"
cat <<'RECAP'
  datumctl console

  ?   help           /   filter         d   describe
  y   yaml           C   conditions     E   events
  H   history        3   quota          4   activity
  c   switch ctx     q   quit
RECAP
printf '\n'
