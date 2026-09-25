# 07 · Give Claude or Cursor access to Datum

| | |
|---|---|
| **Who is it for** | Developers using MCP-enabled tools. |
| **What do they learn** | Install, configure, and use datum-mcp for resource investigation. |
| **Related Datum component** | [datum-mcp](https://github.com/datum-cloud/datum-mcp) |

## Files

- `SCRIPT.md` · video script with narration and on-screen commands
- `demo.sh` · live-demo driver
- `config/claude-code.sh` · registers the server with Claude Code
- `config/claude-desktop.json` · drop-in block for Claude Desktop
- `config/cursor.mcp.json` · drop-in block for Cursor (`.cursor/mcp.json`)

## Prerequisites

- `datum-mcp` installed via the one-line installer (or run it on camera with `DEMO_INSTALL=1`):

  ```sh
  curl -fsSL https://github.com/datum-cloud/datum-mcp/releases/latest/download/install.sh | sh
  ```

- Claude Code installed and signed in. It is the on-camera client.
- A Datum account with a project containing:
  - at least two DNS zones, one of them not yet ready (undelegated nameservers is enough)
  - a few record sets in one zone, including an apex A or AAAA record
  - at least one HTTPProxy, ideally one with and one without a TrafficProtectionPolicy

The investigation beat depends on there being something worth investigating.

## Running the demo

Two panes: this driver on the left, a Claude Code session on the right.

```sh
export DEMO_ORG=my-org
export DEMO_PROJECT=my-project
export DEMO_ZONE=example.com
export DEMO_INSTALL=1     # optional, run the installer on camera
./demo.sh
```

Terminal commands are typed out and run on Enter. Prompts for Claude Code are
printed in yellow for you to paste into the other pane; press Enter in the
driver once Claude has answered. Set `DEMO_TYPE_MS=0` to disable typing.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

## Before recording

1. Complete the OAuth login once off camera so you know the keychain entry
   works, then remove it (see reset) so the on-camera first run shows the
   browser flow.
2. Run every prompt in `demo.sh` once against the demo project and check
   Claude's answers are worth showing. Adjust the prompts to the data.
3. Expand Claude Code's tool-call output so the tool name and action are
   visible on screen.
4. Decide in advance that you will decline the final write prompt.

## Reset between takes

```sh
claude mcp remove datum-mcp --scope user
```

Then remove the stored credential so the next take triggers the browser login
again. On macOS open Keychain Access and delete the datum-mcp entry, or use
`security delete-generic-password` once you have confirmed the service name
it stores under. That name is not documented; check Keychain Access first.

## Unverified

Written from the datum-mcp README and the datum.net docs page; the server was
not run during preparation. Confirm before recording:

- the exact permission prompt Claude Code shows for a write tool call
- the keychain service name used by datum-mcp (needed for the reset step)
- that the `apis` tool returns a schema for `HTTPProxy` in the demo project
