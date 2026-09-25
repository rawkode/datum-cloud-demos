# Deploy a workload to Datum Compute

| | |
|---|---|
| **Audience** | Developers deploying containerised workloads at the edge |
| **Outcome** | Deploy an image, configure location and replicas, and watch the rollout |
| **Component** | [Datum Compute](https://github.com/datum-cloud/compute) and `datumctl compute deploy` |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. One browser cut for the published URL. |

The idea the whole video rests on: **you have an image, you want it running near
your users, and that should be one command.** No YAML to start with, no cluster to
manage, and a URL at the end you can open. The graduation to a manifest comes at
the end, once the audience has seen the easy path work.

Everything in this script was verified against `datumctl compute` v0.8.0 from the
official plugin catalog. Expected output blocks are taken from the plugin's own
design docs and marked where they are illustrative rather than captured.

---

## Cold open (0:00–0:30)

**On screen:** empty terminal, then one line.

```
datumctl compute deploy hello --image=ghcr.io/datum-cloud/hello:latest --city=DFW --http-port=8080
```

Don't run it yet. Hold on the command.

**VO:**
> That's the whole video. One command: an image, a city, a port. What comes
> back is a container running in Dallas, in its own microVM, with an HTTPS URL
> you can open.
>
> Datum Compute runs any OCI image at the network edge. Each instance is a
> hardware-isolated microVM, boots from snapshot in under ten milliseconds,
> and costs nothing while idle. The CLI in front of it is a datumctl plugin,
> and it's built around the things you actually do: deploy, watch the rollout,
> scale, tear down.
>
> Let's run it for real.

**Title card:** *Deploy a workload to Datum Compute*

---

## Beat 1: Install the plugin and check access (0:30–1:20)

**On screen:**

```
datumctl plugin search compute
datumctl plugin install compute
datumctl compute --help
```

**VO:**
> Compute ships as a plugin, so the base CLI stays small. Search the official
> catalogue, install it, and `datumctl compute` appears. The plugin gets your
> login and your current project from datumctl automatically. Nothing else to
> configure.

**On screen:**

```
datumctl compute access
datumctl compute quota
```

**VO:**
> Two things have to be true before anything runs. Compute has to be enabled
> for the project, and the project needs quota. `access` tells you the first,
> `quota` the second. If access isn't granted yet, `datumctl compute access
> request` files the request and Datum approves it.

---

## Beat 2: Deploy with flags (1:20–2:50)

**On screen:** run the cold-open command.

```
datumctl compute deploy hello --image=ghcr.io/datum-cloud/hello:latest --city=DFW --http-port=8080
```

Illustrative output, from the plugin's design docs. Capture the real thing on
the dry run:

```
Resolving workload "hello" in project my-project...
  Workload does not exist — creating.
  Placement "default": selector=[topology.datum.net/city-code=DFW], min=1
  HTTP service:        port 8080 → Datum-managed URL

Apply? (Y/n): y
  workload/hello created

Waiting for rollout. Ctrl-C to detach (rollout continues in background).

  PLACEMENT  LOCATION     UPDATED  READY  OLD  PHASE
  default    dfw-1              1      1    0  Done

Rollout complete in 23s.

Publishing...
  Backends     1 healthy across dfw-1
  Edge         programmed
  Certificate  issued

  https://a1b2c3d4.datumproxy.net
```

**VO, while it resolves:**
> Watch what it does before it touches anything. It resolves the workload
> name, tells you it's going to create rather than update, and shows the
> placement it worked out from `--city`. Dallas is a city; the placement is a
> selector over every location in that city, so if Datum adds capacity there,
> your workload follows.
>
> The HTTP port is the one flag with a side effect worth calling out.
> Declaring it is declaring a web service, and a web service gets a URL. Leave
> it off for a worker and you get an internal workload with no public surface.

**VO, during the rollout table:**
> Then it waits. This is a rollout view, not a spinner. Per placement, per
> location, updated versus ready. Ctrl-C detaches and the rollout carries on.

**VO, on the URL:**
> And the last line is the deliverable. Copy it, open it.

**Browser cut:** open the URL. Show the hello page. Back to terminal.

---

## Beat 3: Inspect what's running (2:50–3:50)

**On screen:**

```
datumctl compute workloads
datumctl compute workloads describe hello
datumctl compute instances --workload=hello
```

Illustrative `describe` output:

```
Workload     hello                           project: my-project
Type         sandbox/datumcloud/d1-standard-2
Updated      1m ago

Health       Available

URL          https://a1b2c3d4.datumproxy.net
Backend      port 8080/tcp

Placements
  default    topology.datum.net/city-code=DFW    scale: 1..1
    dfw-1    ready: 1/1
```

**VO:**
> `workloads` is the list. Locations, health, ready count, image, URL. Every
> column also comes out as JSON with `-o json`, so a `jq` one-liner gets you
> the URL in a script.
>
> `describe` is the single-workload view: config and health together. Which
> instance type, which runtime class, what the placement selector currently
> resolves to, and per-location readiness.
>
> `instances` drops one level. Each row is a microVM. When something's wrong
> in one city and fine in another, this is where you see it.

---

## Beat 4: Scale and spread (3:50–4:50)

**On screen:**

```
datumctl compute scale hello --min=2
datumctl compute rollout hello
```

**VO:**
> `scale` sets the minimum instances per location. Two per location, and the
> rollout starts. `rollout` attaches to it live if you detached, or want to
> watch a change someone else made.

**On screen:**

```
datumctl compute deploy hello --image=ghcr.io/datum-cloud/hello:latest --city=DFW,IAD --http-port=8080
datumctl compute workloads describe hello
```

**VO:**
> Adding a city is the same deploy command with a longer list. It's
> idempotent: deploy resolves the existing workload, shows you what's
> changing, and asks before applying. Now Dallas and Washington, two each,
> behind the same URL. Traffic is served from whichever backends are healthy.

---

## Closing beat: graduate to a manifest (4:50–5:40)

**On screen:**

```
datumctl get workloads
datumctl get workload hello -o yaml
```

**VO:**
> Under the plugin, a workload is a Kubernetes-style resource in the
> `compute.datumapis.com` API group. The plain `datumctl get` you already use
> sees it. Placements, scale settings, the container template. Everything the
> flags set is here as YAML.

**On screen:**

```
cat manifests/hello.yaml
datumctl compute deploy -f manifests/hello.yaml
```

**VO:**
> So when the flags stop being enough, commit the YAML. `deploy -f` takes a
> manifest, diffs it against what's live, and asks. Flags to get started,
> a file in git when it matters. Same command either way.

**On screen:**

```
datumctl compute destroy hello
```

**VO:**
> And `destroy` takes down the workload, its instances, and its URL in one
> go.

**Final card:**

```
datumctl plugin install compute
datumctl compute deploy <name> --image=… --city=… --http-port=…
datumctl compute workloads describe <name>
datumctl compute scale <name> --min=N
datumctl compute deploy -f workload.yaml
```

**VO:**
> Install the plugin, deploy, describe, scale, and graduate to a manifest.
> That's Datum Compute from a terminal.

---

## Cheat sheet for the description / pinned comment

| Task | Command |
|---|---|
| Install the plugin | `datumctl plugin install compute` |
| Check access and quota | `datumctl compute access` · `datumctl compute quota` |
| Deploy with a URL | `datumctl compute deploy api --image=IMG --city=DFW --http-port=8080` |
| Deploy an internal worker | `datumctl compute deploy worker --image=IMG --location=LOC` |
| List workloads | `datumctl compute workloads` |
| Inspect one | `datumctl compute workloads describe api` |
| See the microVMs | `datumctl compute instances --workload=api` |
| Scale per location | `datumctl compute scale api --min=2` |
| Watch a rollout | `datumctl compute rollout api` |
| Rolling restart | `datumctl compute restart api` |
| Manifest-driven | `datumctl compute deploy -f workload.yaml` |
| Tear down | `datumctl compute destroy api` |

## Presenter notes

- **Have Compute enabled and quota granted before recording.** Both are
  manual approvals on Datum's side. `datumctl compute access` should say
  granted and `datumctl compute quota` should show room for at least four
  instances (two cities, two each).
- **Pick the image in advance and confirm it runs on Datum.** The image in
  this script is a placeholder. Use a fully qualified reference to something
  that serves HTTP on 8080, and run `datumctl compute build --analyze` on its
  Dockerfile beforehand if it's yours. An image that runs on a laptop can
  still fail on a microVM.
- **Confirm the city codes and location names.** `--city=DFW,IAD` is from the
  plugin's own examples. Check what locations your project actually has
  before recording and substitute if needed.
- **Rollout timing is the pacing risk.** The first pull of an image is the
  slowest part. Do a full deploy and destroy off-camera first so the image
  is cached where it can be, then time the on-camera run.
- **Expected outputs in this script are illustrative** where marked. They
  match the plugin's design docs for v0.8.0. Capture real output on the dry
  run and update the script if columns differ.
- Terminal at 120 columns. The rollout and workloads tables are wide.
- Skip Beat 4's second city if quota only covers one.
