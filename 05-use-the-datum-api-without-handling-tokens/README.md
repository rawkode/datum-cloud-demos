# 05 · Use the Datum API without handling tokens

| | |
|---|---|
| **Who is it for** | Developers writing scripts and integrations. |
| **What do they learn** | Run the local API proxy and use Datum with tools such as curl. |
| **Related Datum component** | [datumctl api proxy](https://www.datum.net/docs/datumctl/api-proxy) |

Video script and live-demo driver. See [SCRIPT.md](./SCRIPT.md) for the
narration and [demo.sh](./demo.sh) for the command sequence.

## Prerequisites

- `datumctl`, `curl`, `jq`, `python3` on the PATH
- Logged in (`datumctl login`) with a project that has at least two DNS zones
- A terminal with two panes: the proxy on the left, the driver on the right

The DNS zone path uses `dns.networking.miloapis.com/v1alpha1`, the group
defined by the dns-operator CRDs. The proxy's own help text shows an older
`networking.datumapis.com/v1alpha` example; ignore it. Confirm before recording:

```sh
datumctl api-resources --project <project> | grep -i dnszone
```

and set `DEMO_DNS_PATH` to `apis/<group>/<version>/dnszones` accordingly.

## Running the demo

Left pane, started by hand so it is visible on camera:

```sh
datumctl api proxy --port 8001                      # beats 1–2
datumctl api proxy --port 8001 --project my-project # beats 3–5, restart when the driver says so
```

Right pane:

```sh
export DEMO_PROJECT=my-project
export DEMO_DNS_PATH=apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones   # see above
export DEMO_LOGOUT=1   # optional, closing logout/login beat
./demo.sh
```

Set `DEMO_MANAGED=1` to have the driver start and restart the proxy itself
instead of using a second pane. Set `DEMO_TYPE_MS=0` to disable the typing
effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

## Before recording

1. Run `demo.sh` end to end once. Every curl should return JSON, not a 4xx.
2. Have a third terminal ready with `datumctl edit dnszone <name>` so the
   watch beat shows an event streaming through.
3. Widen the right pane. The project-scoped control-plane URLs are long.
4. Do a fresh `datumctl login` shortly before recording so the closing
   logout/login beat is quick.

## Reset between takes

Kill any leftover proxy:

```sh
pkill -f 'datumctl api proxy'
rm -f /tmp/datum-proxy-demo.py /tmp/proxy.url
```

The demo mutates nothing on the platform.
