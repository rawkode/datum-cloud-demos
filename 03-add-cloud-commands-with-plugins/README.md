# 03 · Add cloud commands with plugins

| | |
|---|---|
| **Who is it for** | Engineers extending their cloud workflow. |
| **What do they learn** | Search, install, list, and use Datum plugins. |
| **Related Datum component** | [Datum plugins](https://www.datum.net/docs/datumctl/plugins/using-plugins), starting with DNS. |

Video script and live-demo driver. See [SCRIPT.md](./SCRIPT.md) for the
narration and [demo.sh](./demo.sh) for the command sequence.

## Prerequisites

- `datumctl` installed (`brew install datum-cloud/homebrew-tap/datumctl`)
- Logged in with an active project context (`datumctl whoami` shows a project)
- The project must have DNS service access enabled. Check with
  `datumctl services` if `datumctl dns zone list` returns an entitlement error.
- Shell completion for datumctl installed, so the tab-completion moment in
  Beat 2 works:

  ```sh
  datumctl completion fish > ~/.config/fish/completions/datumctl.fish
  # or: datumctl completion zsh / bash, see `datumctl completion --help`
  ```

- A domain to create as a zone. It does not need to be delegated. The
  `nameservers --check` step reports the honest state either way.

The plugin catalog itself needs nothing. Datum's official catalog is built
into the CLI. `plugin search`, `plugin install`, and `plugin list` all work
without a login.

## Running the demo

```sh
export DEMO_ORG=my-org
export DEMO_PROJECT=my-project
export DEMO_ZONE=example-demo.com   # optional, default shown
export DEMO_CLEANUP=1               # optional, delete the zone and remove the plugin at the end
./demo.sh
```

The driver removes the `dns` plugin before starting so the cold open and the
install beat are real. Each command is typed out, then waits for Enter to run,
then waits for Enter to advance. Set `DEMO_TYPE_MS=0` to disable the typing
effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

At the cold-open prompt, answer `N`. Answering `y` installs the plugin and
makes Beat 1 pointless.

## Before recording

1. Run `datumctl plugin remove dns` and confirm `datumctl plugin list` is
   empty, or at least does not show `dns`.
2. Run `datumctl dns zone list` once after a manual install to confirm the
   project has DNS access and returns something. Then remove the plugin
   again.
3. Delete any leftover zone named `$DEMO_ZONE` from a previous take.
4. Terminal at 130 columns or wider. The search table is wide.
5. Clear shell history and any prompt decorations that show the current
   directory or git branch.

## Reset between takes

```sh
datumctl dns zone delete "$DEMO_ZONE" --yes
datumctl plugin remove dns
```

Or run with `DEMO_CLEANUP=1` and the driver does both at the end. The plugin
install writes to `~/.datumctl/plugins/` and nothing else on the client.
