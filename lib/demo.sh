# Shared helpers for every demo.sh driver. Source it, don't run it:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"
#
# Two rules keep the recording clean:
#
#   1. Presenter notes never go to the recorded terminal. `note` appends them
#      to $DEMO_NOTES; keep `tail -f "$DEMO_NOTES"` open on a second screen.
#   2. Every wait is a plain `read -r`. Never `read -s` or `stty -echo`: that
#      clears the tty ECHO bit, and Ghostty shows its password-input lock on
#      camera whenever echo is off. Pressing Enter echoes a newline, so nothing
#      prints an explicit newline after a wait.
#
# Env vars:
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)
#   DEMO_NOTES     presenter notes file (default: $TMPDIR/datum-demo-notes)

DEMO_TYPE_MS="${DEMO_TYPE_MS:-25}"
DEMO_NOTES="${DEMO_NOTES:-${TMPDIR:-/tmp}/datum-demo-notes}"

bold=$'\e[1m'; dim=$'\e[2m'; cyan=$'\e[36m'; green=$'\e[32m'; yellow=$'\e[33m'; reset=$'\e[0m'
_demo_delay="$(awk "BEGIN{print ${DEMO_TYPE_MS}/1000}")"

# type_out "<text>"  — print with a per-character delay
type_out() {
  local s="$1" i
  if [[ "$DEMO_TYPE_MS" == "0" ]]; then printf '%s' "$s"; return; fi
  for ((i = 0; i < ${#s}; i++)); do
    printf '%s' "${s:i:1}"
    sleep "$_demo_delay"
  done
}

# note "<text>"...  — presenter-only; one line per argument, appended to $DEMO_NOTES
note() { printf '%s\n' "$@" >> "$DEMO_NOTES"; }

# pause  — wait for Enter
pause() { read -r; }

# run "<command>"  — typed out, run on Enter, then waits for Enter to advance
run() {
  local cmd="$1"
  printf '%s$ %s' "$green" "$reset"
  type_out "${bold}${cmd}${reset}"
  pause
  eval "$cmd" || true
  pause
}

# prompt "<text>"  — a prompt to paste into another tool (e.g. Claude Code); waits for Enter
prompt() {
  printf '%s> %s' "$yellow" "$reset"
  type_out "${bold}$1${reset}"
  note "paste the prompt above into the other pane, then press Enter here"
  pause
}

note "" "=== $(basename "$(cd "$(dirname "$0")" && pwd)") ==="
