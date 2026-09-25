# Use the Datum API without handling tokens

| | |
|---|---|
| **Audience** | Developers writing scripts and integrations |
| **Outcome** | Run the local API proxy and use Datum with tools such as curl |
| **Component** | [datumctl api proxy](https://www.datum.net/docs/datumctl/api-proxy) |
| **Target length** | 4–5 minutes |
| **Format** | Terminal screen recording with voice-over. Two panes: proxy on the left, client commands on the right. |

The idea: **the Datum API is a Kubernetes-style HTTP API, and datumctl will
front it for you on localhost.** Your script talks plain HTTP to `127.0.0.1`
with no auth header at all. datumctl adds the bearer token, refreshes it when
it expires, and you never see a token. Show the painful way once, then never
again.

---

## Cold open (0:00–0:30)

**On screen:** the way everyone does it first.

```
TOKEN=$(datumctl auth get-token)
curl -H "Authorization: Bearer $TOKEN" \
  https://api.datum.net/apis/resourcemanager.miloapis.com/v1alpha1/organizations
```

**VO:**
> This works. `get-token` prints a bearer token, you pass it to curl, done.
> And then an hour later it expires, and your script is now a token-refresh
> loop with a side business in HTTP.
>
> Tokens are datumctl's problem. Let's keep it that way.

**Title card:** *Use the Datum API without handling tokens*

---

## Beat 1: Start the proxy (0:30–1:30)

**On screen, left pane:**

```
datumctl api proxy --port 8001
```

Leave it running. Point out the first stdout line, which is the bare URL,
and the session line on stderr.

**VO:**
> `datumctl api proxy` starts an HTTP server on loopback. Every request you
> send it gets forwarded to the Datum API for your active session, with your
> credentials attached. If the token is about to expire, the proxy refreshes
> it. If you switch account or context later, the proxy doesn't care: session
> and scope are pinned when it starts.
>
> The first line on stdout is just the URL. That's deliberate. A script can
> start the proxy, read one line, and know where to send traffic.

**On screen, right pane:**

```
curl -s http://127.0.0.1:8001/apis/resourcemanager.miloapis.com/v1alpha1/organizations | jq '.items[].metadata.name'
```

**VO:**
> No auth header. No token. The proxy strips whatever you send and replaces
> it with the real credential. And the response is exactly what the API
> returns, so `jq` works the way it does against any Kubernetes API.

---

## Beat 2: The API has the shape you expect (1:30–2:30)

**On screen:**

```
curl -s http://127.0.0.1:8001/apis | jq '.groups[].name'
```

**VO:**
> This is the Kubernetes discovery endpoint, served by Datum. If you've ever
> poked at a kube-apiserver with curl, you already know the URL scheme:
> `/apis`, then group, then version, then resource.
>
> Organisations and projects live at the platform root. Each project has its
> own control plane at a longer path.

**On screen:**

```
curl -s "http://127.0.0.1:8001/apis/resourcemanager.miloapis.com/v1alpha1/projects/${DEMO_PROJECT}/control-plane/apis" | jq '.groups[].name'
```

**VO:**
> Same discovery endpoint, one level down. Everything datumctl shows you in
> `api-resources` is reachable this way.

---

## Beat 3: Scope the proxy to a project (2:30–3:30)

**On screen, left pane:** stop the proxy, restart it scoped.

```
datumctl api proxy --port 8001 --project ${DEMO_PROJECT}
```

**On screen, right pane:**

```
curl -s http://127.0.0.1:8001/apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones | jq '.items[].metadata.name'
datumctl get dnszones -o json | jq '.items[].metadata.name'
```

**VO:**
> Pass `--project` and the proxy's root *is* that project's control plane.
> The long prefix disappears. Now your script's URLs look like any other
> Kubernetes API, and they're identical to what `datumctl get -o json`
> returns, because it's the same API call.

**On screen:**

```
curl -sN "http://127.0.0.1:8001/apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones?watch=true"
```

Let it sit for a beat. If you can, edit a zone in another terminal so an
event streams through.

**VO:**
> Watches stream straight through, unbuffered. That's the same `?watch=true`
> kubectl uses under the hood.

---

## Beat 4: Use it from code (3:30–4:20)

**On screen:** a short Python script, run it.

```python
import json, urllib.request

PROXY = "http://127.0.0.1:8001"
url = f"{PROXY}/apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones"
with urllib.request.urlopen(url) as r:
    for z in json.load(r)["items"]:
        print(z["metadata"]["name"])
```

**VO:**
> No SDK, no auth library, no credentials in the environment. Any HTTP
> client in any language works, because from the script's point of view it's
> talking to an unauthenticated server on localhost.
>
> If you want the proxy fully managed by the script, start it as a
> subprocess with `--quiet`, read the first line of stdout for the URL, and
> kill it on exit. That's the whole integration.

**On screen:**

```
URL=$(datumctl api proxy --quiet --project ${DEMO_PROJECT} & sleep 1; ...)
```

Presenter: the real one-liner is in `demo.sh`. Show that instead of typing
it live.

---

## Closing beat (4:20–4:50)

**On screen:**

```
datumctl logout
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8001/apis
datumctl login
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8001/apis
```

**VO:**
> Last thing. Log out while the proxy is running and it starts returning
> 502. Log back in and it recovers on its own. Your script never touched a
> credential in either direction.
>
> Start the proxy, point your tools at localhost. Datum handles the rest.

**Final card:**

```
datumctl api proxy --port 8001 --project <project>
curl http://127.0.0.1:8001/apis/<group>/<version>/<resource>
```

---

## Cheat sheet for the description / pinned comment

| Task | Command |
|---|---|
| Start proxy, platform root | `datumctl api proxy --port 8001` |
| Start proxy, one project | `datumctl api proxy --port 8001 --project <project>` |
| Start proxy, one organisation | `datumctl api proxy --port 8001 --organization <org>` |
| Random port, URL on stdout line 1 | `datumctl api proxy --quiet` |
| Pin a non-active session | `datumctl api proxy --session <name>` (see `datumctl auth list`) |
| List organisations | `curl http://127.0.0.1:8001/apis/resourcemanager.miloapis.com/v1alpha1/organizations` |
| Discover API groups | `curl http://127.0.0.1:8001/apis` |
| Watch a resource | `curl -N "http://127.0.0.1:8001/apis/<group>/<version>/<resource>?watch=true"` |
| Raw token (the old way) | `datumctl auth get-token` |

## Presenter notes

- Two panes. The proxy logs every request on stderr unless `--quiet`, and
  those log lines are good B-roll: you can see each curl land.
- The DNS zone path uses `dns.networking.miloapis.com/v1alpha1`, which is
  the group in the dns-operator CRDs. The proxy's own help text still shows
  an older `networking.datumapis.com/v1alpha` example; ignore it. Confirm
  with `datumctl api-resources` before recording and set `DEMO_DNS_PATH` if
  your platform reports something different.
- The proxy only accepts loopback Host headers. If your terminal multiplexer
  or a container tries to reach it via another hostname, expect 403.
- For the watch beat, have a second terminal ready to `datumctl edit` or
  `datumctl apply` a zone so an event streams through on camera.
- The logout / login closing beat opens a browser. Do it last so a slow
  OAuth round trip doesn't stall the middle of the video.
