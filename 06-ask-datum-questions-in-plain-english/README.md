# 06 · Ask Datum questions in plain English

| | |
|---|---|
| **Who is it for** | Engineers using AI to investigate infrastructure. |
| **What do they learn** | Query resources with natural language and understand approval boundaries. |
| **Related Datum component** | [datumctl ai](https://www.datum.net/docs/datumctl/ai/assistant) |

Video script and live-demo driver. See [SCRIPT.md](./SCRIPT.md) for the
narration and [demo.sh](./demo.sh) for the command sequence.

## Prerequisites

- `datumctl` installed and logged in (`datumctl login`)
- An API key for one supported provider: Anthropic (`ANTHROPIC_API_KEY`),
  OpenAI (`OPENAI_API_KEY`) or Gemini (`GEMINI_API_KEY`). Save it once,
  off camera:

  ```sh
  datumctl ai config set anthropic_api_key sk-ant-...
  ```

- A project with at least two DNS zones, ideally one that is not yet Ready
  (for example, a zone whose nameservers have not been delegated) so the
  "which zones have a problem" question has something to report.

Create a zone if you need one:

```sh
datumctl apply --project <project> -f - <<'YAML'
apiVersion: dns.networking.miloapis.com/v1alpha1
kind: DNSZone
metadata:
  name: example-com
spec:
  domainName: example.com
  dnsZoneClassName: datum-external-global-dns
YAML
```

Check the exact schema first with `datumctl explain dnszones.spec`.

## Running the demo

```sh
export DEMO_PROJECT=my-project
export DEMO_ZONE=example-com          # optional, the zone to inspect by name
export DEMO_MODEL=claude-sonnet-4-6   # optional, passes --model on every call
./demo.sh
```

Each command is typed out, then waits for Enter to run, then waits for Enter
to advance. Set `DEMO_TYPE_MS=0` to disable the typing effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

Beat 3 starts an interactive `datumctl ai` session and hands the keyboard to
you. The driver prints the questions to type; answer `n` at the first
`Apply changes? [y/N]:` prompt, `y` at the next two, then `exit`.

## Before recording

1. Save the API key with `ai config set` off camera. The script only runs
   `config show` on camera, which redacts the key.
2. Run through `demo.sh` once end to end. Model output varies between runs;
   pick the phrasing that gives the cleanest answers and keep it.
3. Confirm the interactive beat actually reaches the `--- Proposed action ---`
   preview with your model and project. That block is the point of the video.
4. Terminal at 100 columns or wider so the YAML in the preview does not wrap
   badly.

## Reset between takes

The interactive beat creates and then deletes a `_demo` TXT record. If a take
is aborted between the apply and the delete, remove it by hand:

```sh
datumctl get dnsrecordsets --project <project>
datumctl delete dnsrecordset <name> --project <project>
```

To clear the saved default project:

```sh
datumctl ai config unset project
```

The API key stays in `~/.config/datumctl/ai.yaml` until you `config unset` it.
