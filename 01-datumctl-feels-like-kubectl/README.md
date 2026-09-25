# 01 · datumctl feels like kubectl

Video script and live-demo driver. See [SCRIPT.md](./SCRIPT.md) for the
narration and [demo.sh](./demo.sh) for the command sequence.

## Prerequisites

- `datumctl` installed (`brew install datum-cloud/homebrew-tap/datumctl`)
- `kubectl` installed (for the cold open and the closing beat)
- A Datum account with:
  - at least one organisation and one project (two contexts is better)
  - at least two DNS zones in the demo project
  - one zone labelled `env=prod` so the label-selector beat filters visibly

Create a zone if you need one:

```sh
datumctl apply --project <project> -f - <<'YAML'
apiVersion: dns.networking.miloapis.com/v1alpha1
kind: DNSZone
metadata:
  name: example-com
  labels:
    env: prod
spec:
  domainName: example.com
  dnsZoneClassName: datum-external-global-dns
YAML
```

Check the exact schema first with `datumctl explain dnszones.spec`; field names
follow the platform version you are connected to.

## Running the demo

```sh
export DEMO_ORG=my-org
export DEMO_PROJECT=my-project
export DEMO_ALT_CTX=my-org/staging   # optional, a second context to switch through
export DEMO_ZONE=example-com          # optional, defaults to first zone found
export DEMO_KUBECONFIG=~/.kube/datum  # optional, scratch kubeconfig for the closing beat
export DEMO_KUBECTL=0                 # optional, skip the closing plain-kubectl beat
./demo.sh
```

Each command is typed out, then waits for Enter to run, then waits for Enter
to advance. Set `DEMO_TYPE_MS=0` to disable the typing effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

## Before recording

1. Log in once off-camera so the browser has a session. The on-camera
   `datumctl logout` then `datumctl login` will be quick.
2. Run through `demo.sh` once end to end and confirm every command returns
   something worth looking at.
3. Terminal at 120 columns or wider. `api-resources -o wide` needs the room.
4. Clear shell history and any prompt decorations that show the current
   directory or git branch.

## Reset between takes

```sh
datumctl logout
```

The closing beat writes a kubeconfig to `$DEMO_KUBECONFIG` (default
`~/.kube/datum`). It never touches `~/.kube/config`. Remove it with:

```sh
rm ~/.kube/datum
```

Those are the only two pieces of client state the demo mutates.
