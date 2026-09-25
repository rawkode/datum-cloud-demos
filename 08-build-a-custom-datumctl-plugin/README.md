# 08 · Build a custom datumctl plugin

| | |
|---|---|
| **Who is it for** | Go developers extending Datum. |
| **What do they learn** | Build, install, and run a custom datumctl command. |
| **Related Datum component** | [Plugin SDK](https://www.datum.net/docs/datumctl/plugins/building-plugins) |

## Files

- `SCRIPT.md` · video script with narration and on-screen commands
- `demo.sh` · live-demo driver
- `plugin/` · the plugin built in the video (`datumctl zones`), a Go module
  depending on the published SDK at `go.datum.net/datumctl/plugin`

## What the plugin does

`datumctl zones` adds two subcommands:

- `context` prints the six `DATUM_*` values datumctl injected. No network.
- `summary` fetches a token via the credentials helper, lists DNS zones on
  the project control plane, and prints a count plus how many are `Ready`.
  Supports `-o json` and `--project`.

## Prerequisites

- Go 1.25 or newer
- `datumctl` installed and logged in, with an active project context
  (`datumctl whoami` should show a project)
- Three or more DNS zones in that project so the summary has something to say
- Optional: a second project for the `--project` override beat
- Optional: the `compute` plugin installed so `plugin list` is non-empty in
  the closing beat (`datumctl plugin install compute`)

Verify the plugin builds before anything else:

```sh
cd plugin && go build -o ../bin/datumctl-zones . && ../bin/datumctl-zones --plugin-manifest
```

## Running the demo

```sh
export DEMO_PROJECT=my-project
export DEMO_ALT_PROJECT=other-project   # optional
./demo.sh
```

The driver deletes `bin/`, revokes any existing trust for `zones`, rebuilds,
then walks the beats. Each command is typed out, waits for Enter to run, then
waits for Enter to advance. Set `DEMO_TYPE_MS=0` to disable the typing effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

## Before recording

1. Run `demo.sh` end to end once. The `summary` beat makes a real API call and
   was not verified against a live project while writing this. If it returns
   an error, check the URL in `plugin/main.go` against
   `datumctl api-resources --api-group=dns.networking.miloapis.com`.
2. Open `plugin/main.go` in an editor pane at 90 columns for Beat 1.
3. Terminal at 100 columns or wider.
4. Clear shell history and prompt decorations.

## Reset between takes

```sh
datumctl plugin untrust zones
rm -rf bin
```

`demo.sh` does both on start, so a rerun is enough. Nothing is written to
`~/.datumctl/plugins/`; trust lives in `plugins.json` there and `untrust`
removes it.

## Known limits

- `datumctl plugin list` shows managed (installed) plugins only. A trusted
  PATH plugin does not appear. The script uses `zones context` and tab
  completion as proof of registration instead.
- Rebuilding the binary changes its hash and invalidates trust. Trust again
  after any edit.
