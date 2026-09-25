# 02 · Explore Datum from a terminal UI

| | |
|---|---|
| **Who is it for** | Developers who prefer visual exploration. |
| **What do they learn** | Browse resources, inspect YAML, view events, and check platform health. |
| **Related Datum component** | [datumctl console](https://www.datum.net/docs/datumctl/console) |

Video script and live-demo driver. See [SCRIPT.md](./SCRIPT.md) for the
narration and keystroke walkthrough, and [demo.sh](./demo.sh) for the launcher.

## Prerequisites

- `datumctl` installed (`brew install datum-cloud/homebrew-tap/datumctl`)
- Logged in (`datumctl login`) with a project context selected
- A demo project with:
  - several DNS zones (the browse and filter beats need a list worth scrolling)
  - one zone with at least two revisions, so the `H` history view has a diff
  - ideally one governed resource type near its quota, so platform health
    shows a flagged row instead of "all clear"
- A second org or project for the `c` context-switch beat
- Terminal at 120 columns × 40 rows or larger

To give a zone a second revision before recording:

```sh
datumctl edit dnszone <name> --project <project>
# add or change a label, save, quit
```

## Running the demo

```sh
export DEMO_ORG=my-org
export DEMO_PROJECT=my-project
export DEMO_ALT_CTX=my-org/staging   # optional, for the [c] beat
./demo.sh
```

The driver checks terminal size, switches to the demo context, writes the
keystroke plan to `$DEMO_NOTES` (default `$TMPDIR/datum-demo-notes`), then
launches `datumctl console --read-only`. Keep `tail -f "$DEMO_NOTES"` open on
a second screen and follow the plan by hand. Nothing presenter-facing is
printed to the recorded terminal. Set `DEMO_READ_ONLY=0` to launch without
the read-only guard.

## Before recording

1. Open the console once off-camera and press `E` on the zone you plan to
   describe, so the events fetch is warm.
2. Press `3` and confirm the quota dashboard has buckets to show. If it says
   "No allowance buckets configured", pick a different project.
3. Confirm the welcome dashboard shows all four sections: header, platform
   health with bars, recent activity, quick-jump keys. If any is missing the
   terminal is too small.
4. Clear shell history and prompt decorations.

## Reset between takes

Nothing on the platform is mutated when running with `--read-only`. On the
client, the console remembers AI chat conversations only; the browse state
resets on every launch. If you switched contexts during a take:

```sh
datumctl ctx use <org>/<project>
```
