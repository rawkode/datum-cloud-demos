# datumctl feels like kubectl

| | |
|---|---|
| **Audience** | Kubernetes users exploring Datum |
| **Outcome** | Authenticate, switch context, discover resources, use `get` and `describe` |
| **Component** | [datumctl](https://github.com/datum-cloud/datumctl) |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. Optional split screen for the kubectl comparison beats. |

The whole video rests on one idea: **if you know kubectl, you already know datumctl.**
Every beat shows a kubectl habit, then the identical datumctl command. Don't explain
the Kubernetes concepts. The audience already has them. Explain only what Datum adds:
organisations and projects as the context model, and a resource catalogue you can
discover instead of memorise.

---

## Cold open (0:00–0:25)

**On screen:** empty terminal, then type one line.

```
kubectl get pods
```

**VO:**
> If you've spent any time with Kubernetes, your fingers know this command. `get`,
> `describe`, `apply`, contexts, `api-resources`. That muscle memory is the whole
> reason datumctl exists.
>
> Datum's control plane *is* a Kubernetes API server. So the CLI doesn't wrap a
> REST API and invent new verbs. It gives you kubectl's verbs, kubectl's flags,
> and kubectl's output formats, pointed at Datum's resources.
>
> Let's prove it. Five minutes, four things: log in, pick a context, find out
> what's there, and inspect it.

**Title card:** *datumctl feels like kubectl*

---

## Beat 1: Install and authenticate (0:25–1:30)

**On screen:**

```
brew tap datum-cloud/homebrew-tap
brew install datumctl
datumctl version
```

**VO:**
> Homebrew on macOS. There's also a Nix flake and prebuilt binaries for Linux
> and Windows. One binary, no kubeconfig needed yet.

**On screen:**

```
datumctl login
```

Browser opens. Complete sign-in. Come back to the terminal and show the context
picker. Choose a project context.

**VO:**
> `login` is OAuth with PKCE. Your browser does the sign-in, the CLI gets a
> refresh token, and it goes in your OS keyring. No static API keys, no token
> to paste.
>
> Here's the first Datum-specific thing. Once you're authenticated, datumctl
> discovers every organisation and project you can reach and asks you to pick
> a default. That's the equivalent of `kubectl config use-context`, done for
> you at login.
>
> Headless box? `datumctl login --no-browser` gives you a device code instead.
> CI? Point it at a service-account credentials file.

**On screen:**

```
datumctl whoami
```

Expected shape:

```
User:         David Flanagan (david@example.com)
Context:      my-org/my-project
Organization: My Org (my-org)
Project:      My Project (my-project)
```

**VO:**
> `whoami` confirms who you are and where your commands will land. Keep this
> one in your pocket. It's the fastest answer to "wait, which project am I in?"

---

## Beat 2: Contexts (1:30–2:30)

**On screen, optionally split with kubectl on the left:**

```
kubectl config get-contexts          |   datumctl ctx
kubectl config current-context       |   datumctl whoami
kubectl config use-context staging   |   datumctl ctx use my-org/staging
```

Run the datumctl side live:

```
datumctl ctx
```

**VO:**
> A kubectl context is a cluster plus a user plus a namespace. A Datum context
> is an organisation, optionally narrowed to a project. Organisations own
> projects, and each one is its own control plane with its own set of
> resources. `datumctl ctx` shows the tree.

```
datumctl ctx use my-org/my-project
```

**VO:**
> Switching is `ctx use`, with the org and project separated by a slash. Give
> it nothing and you get the same interactive picker you saw at login.
>
> And exactly like kubectl's `--context` flag, you can override per command
> instead of switching. Use `--project` or `--organization` on any command,
> or set `DATUM_PROJECT` in the environment. Handy in scripts.

**On screen:**

```
datumctl get projects --organization my-org
DATUM_PROJECT=other-project datumctl get dnszones
```

---

## Beat 3: Discover resources (2:30–3:45)

**On screen:**

```
datumctl api-resources
```

**VO:**
> Now the question every Kubernetes user asks on a new cluster: what's actually
> installed here? Same answer as always.
>
> `api-resources` is fetched live from the control plane you're pointed at, so
> it reflects exactly this platform version. You'll see names, short names,
> API groups, and kinds, the same columns kubectl gives you.

Scroll or filter to highlight a few: `dnszones`, `domains`, `httpproxies`,
`locations`, `projects`.

```
datumctl api-resources --api-group=dns.networking.miloapis.com
datumctl api-resources -o wide
```

**VO:**
> Filter by API group, or add `-o wide` for the supported verbs. Notice the
> group names end in `miloapis.com` and `datumapis.com`. These are real CRDs on a real API server.

**On screen:**

```
datumctl explain dnszones
datumctl explain dnszones.spec
```

**VO:**
> And when you want to know what a field means before you write a manifest,
> `explain` pulls the OpenAPI schema straight from the server. Dot notation
> walks into nested fields, exactly like kubectl.

---

## Beat 4: get and describe (3:45–5:00)

**On screen:**

```
datumctl get dnszones
```

**VO:**
> `get` gives you the table. Same printer as kubectl, so every output flag
> you already use works.

```
datumctl get dnszones -o wide
datumctl get dnszones -o yaml
datumctl get dnszones -o jsonpath='{.items[*].metadata.name}'
datumctl get dnszones -l env=prod
datumctl get dnszones --watch
```

**VO:**
> `-o wide`. `-o yaml`. JSONPath. Label selectors. `--watch`. Nothing new to
> learn, and every existing script or alias you've built around kubectl output
> keeps working.

**On screen:**

```
datumctl describe dnszone example-com
```

**VO:**
> `describe` is where you go when something isn't ready. Status conditions,
> related events, the full picture. Prefix matching works too: give it the
> first few characters of a name and it describes everything that matches.

Pause on the `Conditions` block in the output.

**VO:**
> If you've ever debugged a Deployment by reading its conditions, this is the
> same workflow. Same shape, same place to look.

---

## Closing beat: the surprise (5:00–5:45)

Don't telegraph this one. Beats 1–4 have been "datumctl is *like* kubectl".
This beat is "it *is* kubectl". Say nothing while the first command types.

**On screen:**

```
datumctl auth update-kubeconfig --project my-project --kubeconfig ~/.kube/datum
export KUBECONFIG=~/.kube/datum
kubectl api-resources --api-group=dns.networking.miloapis.com
kubectl get dnszones
kubectl describe dnszone example-com
```

**VO:**
> One last thing. I've been saying datumctl *feels* like kubectl. Let me put
> datumctl down.
>
> That command wrote an ordinary kubeconfig entry. The cluster is your Datum
> project's control plane, and the user is an exec credential plugin: kubectl
> asks datumctl for a token on every request, so there's no key to paste and
> nothing to expire in a file.
>
> And now it's just kubectl. Same resources. Same table. Same `describe`.

**On screen:**

```
kubectl config view --minify
```

Pause on the `exec:` block.

**VO:**
> That's the whole trick. Datum's control plane is a Kubernetes API server, so
> every tool that speaks kubeconfig already works: kubectl, k9s, Helm, your
> Terraform provider, your IDE. datumctl isn't pretending to be kubectl. It's
> kubectl's toolkit pointed at Datum, with login and context discovery added
> so you don't have to wire any of this up yourself.

**On screen, final card:**

```
datumctl login
datumctl ctx
datumctl api-resources
datumctl get <resource>
datumctl describe <resource> <name>

datumctl auth update-kubeconfig --project <project>
kubectl get <resource>
```

**VO:**
> Log in, pick a context, discover, get, describe. And when you're ready,
> hand the kubeconfig to any tool you like. If you know kubectl, you knew
> all of this already.
>
> Links to the install docs and the datumctl repo are below.

---

## Cheat sheet for the description / pinned comment

| kubectl | datumctl |
|---|---|
| `kubectl config get-contexts` | `datumctl ctx` |
| `kubectl config current-context` | `datumctl whoami` |
| `kubectl config use-context X` | `datumctl ctx use org/project` |
| `kubectl --context X ...` | `datumctl --project X ...` |
| `kubectl api-resources` | `datumctl api-resources` |
| `kubectl explain TYPE` | `datumctl explain TYPE` |
| `kubectl get TYPE -o yaml` | `datumctl get TYPE -o yaml` |
| `kubectl describe TYPE NAME` | `datumctl describe TYPE NAME` |
| *(n/a)* | `datumctl login` |
| *(n/a)* | `datumctl auth update-kubeconfig --project X` |

## Presenter notes

- Do the browser login **before** recording, then `datumctl logout` on camera
  and log in again so the OAuth round trip is fast and the picker shows up.
- Have at least two contexts so `ctx` and `ctx use` show a real switch.
- Have at least two DNS zones in the demo project, with one label
  (`env=prod`) on one of them so the selector beat filters visibly.
- Set `--request-timeout` low if the network is flaky; a hanging `get` kills
  the pacing.
- Widen the terminal to 120 columns. `api-resources -o wide` is wide.
- The closing beat writes to `~/.kube/datum`, never `~/.kube/config`, so
  your real kubeconfig is untouched. `rm ~/.kube/datum` resets it.
- The kubeconfig path is passed as a separate argument (`--kubeconfig ~/x`),
  not `--kubeconfig=~/x`. Fish does not tilde-expand after `=`, and the driver
  runs under bash anyway, but keep the habit if you ever type it by hand.
- If time is tight, `DEMO_KUBECTL=0` skips the closing beat. Beats 1–4 stand
  alone, but the surprise is the best thirty seconds of the video.
