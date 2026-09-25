#!/usr/bin/env bash
#
# Live-demo driver for "Give Claude or Cursor access to Datum".
#
# Terminal steps are typed out and run on Enter. Steps that happen inside the
# Claude Code session are shown as prompts for you to paste; the driver waits
# while you run them in the other pane.
#
# Configure with env vars (see README.md):
#   DEMO_ORG       organisation id            (required)
#   DEMO_PROJECT   project id                 (required)
#   DEMO_ZONE      a DNS zone name to inspect (required)
#   DEMO_INSTALL   set to 1 to run the curl installer on camera (default: 0, assumes installed)
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_ORG:?set DEMO_ORG}"
: "${DEMO_PROJECT:?set DEMO_PROJECT}"
: "${DEMO_ZONE:?set DEMO_ZONE}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear

note "Cold open: ask first, explain later"
prompt "Which of my DNS zones aren't ready yet, and why?"
pause; clear

note "Beat 1: install"
if [[ "${DEMO_INSTALL:-0}" == "1" ]]; then
  run "curl -fsSL https://github.com/datum-cloud/datum-mcp/releases/latest/download/install.sh | sh"
fi
run "which datum-mcp"
pause; clear

note "Beat 2: register with your client"
run "claude mcp remove datum-mcp --scope user 2>/dev/null; true"
run "claude mcp add --scope user datum-mcp -- datum-mcp"
run "claude mcp list"
note "Same block for Claude Desktop and Cursor"
run "cat ${HERE}/config/claude-desktop.json"
run "cat ${HERE}/config/cursor.mcp.json"
pause; clear

note "Beat 3: first run and login   (switch to the Claude Code pane)"
run "echo 'now run: claude'"
prompt "Which Datum organisations am I a member of?"
prompt "Set my active organisation to ${DEMO_ORG}, then list its projects and set ${DEMO_PROJECT} as active."
pause; clear

note "Beat 4: investigate"
prompt "List the DNS zones in this project and flag any that aren't ready."
prompt "Show me every record set for ${DEMO_ZONE} and check whether the apex has both A and AAAA records."
prompt "What fields does a Datum HTTPProxy spec support, and which are required?"
prompt "Which HTTP proxies route to backends that don't have a traffic protection policy?"
pause; clear

note "Closing: where the line is   (DECLINE the permission prompt)"
prompt "Add a TXT record \"hello\" to the apex of ${DEMO_ZONE}."
pause; clear

note "Recap"
cat <<'RECAP'
  curl -fsSL .../install.sh | sh
  claude mcp add datum-mcp -- datum-mcp
  > Which of my DNS zones aren't ready yet?

  Install, register, ask. What it may change is still up to you.
RECAP
printf '\n'
