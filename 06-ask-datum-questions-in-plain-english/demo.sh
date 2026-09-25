#!/usr/bin/env bash
#
# Live-demo driver for "Ask Datum questions in plain English".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_PROJECT   project id                          (required)
#   DEMO_ZONE      a DNS zone name to inspect           (default: example-com)
#   DEMO_MODEL     optional --model override, e.g. claude-sonnet-4-6
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)
#
# The interactive session (beat 3) hands control to you: type the questions
# from SCRIPT.md at the Patch prompt and 'exit' when done.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_ZONE="${DEMO_ZONE:-example-com}"
MODEL_FLAG=""
[[ -n "${DEMO_MODEL:-}" ]] && MODEL_FLAG=" --model ${DEMO_MODEL}"

if [[ -z "${ANTHROPIC_API_KEY:-}${OPENAI_API_KEY:-}${GEMINI_API_KEY:-}" ]] \
   && ! datumctl ai config show 2>/dev/null | grep -qi "api_key"; then
  echo "No LLM API key found. Run: datumctl ai config set anthropic_api_key sk-ant-..." >&2
  exit 1
fi

clear

note "Cold open: ask the question you'd otherwise script"
run "datumctl ai \"which of my DNS zones aren't ready yet?\"${MODEL_FLAG}"
pause; clear

note "Beat 1: setup  (key was saved off-camera; show redacted config)"
run "datumctl whoami"
run "datumctl ai config set project ${DEMO_PROJECT}"
run "datumctl ai config show"
pause; clear

note "Beat 2: read-only questions run immediately"
run "datumctl ai \"what kinds of resources can I manage in this project?\"${MODEL_FLAG}"
run "datumctl ai \"list my DNS zones and tell me which ones have a problem\"${MODEL_FLAG}"
run "datumctl ai \"show me the full spec of the ${DEMO_ZONE} zone as YAML\"${MODEL_FLAG}"
pause; clear

note "Beat 3: interactive session — writes stop at the approval prompt"
cat >> "$DEMO_NOTES" <<'HINT'
  At the Patch prompt, type in order:
    > which DNS zone was created most recently?
    > add a TXT record to it called _demo with the value "hello from patch"
        -> answer  n  at 'Apply changes? [y/N]:'
    > ok, go ahead and add it
        -> answer  y
    > now delete that record
        -> answer  y
    > exit
HINT
run "datumctl ai${MODEL_FLAG}"
pause; clear

note "Beat 4: pipe mode is read-only by design"
run "echo \"how many DNS zones do I have?\" | datumctl ai${MODEL_FLAG}"
run "echo \"delete the ${DEMO_ZONE} zone\" | datumctl ai${MODEL_FLAG}"
pause; clear

note "Recap"
cat <<'RECAP'
  datumctl ai config set anthropic_api_key ...
  datumctl ai "any question"
  datumctl ai                      # interactive session
  echo "question" | datumctl ai    # read-only pipe mode

  Reads run. Writes ask. Pipes can't write at all.
RECAP
printf '\n'
