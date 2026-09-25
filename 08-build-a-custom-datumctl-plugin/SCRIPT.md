# Build a custom datumctl plugin

| | |
|---|---|
| **Audience** | Go developers extending Datum |
| **Outcome** | Build, install, and run a custom datumctl command |
| **Component** | [Plugin SDK](https://www.datum.net/docs/datumctl/plugins/building-plugins) |
| **Target length** | 6–7 minutes |
| **Format** | Terminal screen recording with an editor pane for the Go source. Voice-over. |

One idea carries the video: **a datumctl plugin is just a binary that follows a
tiny contract.** Name it `datumctl-<name>`, answer `--plugin-manifest`, read six
environment variables, and ask datumctl for a token when you need one. The Go
SDK makes each of those a one-liner. Everything else is ordinary Cobra.

The plugin we build is `datumctl zones`, about 100 lines, in `plugin/main.go`
next to this script. Keep the editor on it for the whole first half.

---

## Cold open (0:00–0:25)

**On screen:**

```
datumctl zones summary
```

Output is an error: datumctl has no `zones` command.

**VO:**
> datumctl doesn't have a `zones summary` command. By the end of this video it
> will, and it'll be one we wrote ourselves. Not a fork, not a patch to
> datumctl. A separate Go binary that datumctl discovers, trusts, and hands
> credentials to.
>
> If you've written a kubectl plugin, this is the same shape. If you haven't,
> it's about a hundred lines and there's nothing clever in it.

**Title card:** *Build a custom datumctl plugin*

---

## Beat 1: The contract (0:25–1:45)

**On screen:** open `plugin/main.go` in the editor. Scroll slowly through the
top of the file as you talk. Highlight in this order: the import, the manifest
var, `ServeManifest`, `NewRootCmd`.

```go
import "go.datum.net/datumctl/plugin"

var manifest = plugin.Manifest{
    Name:          "zones",
    Version:       "v0.1.0",
    Description:   "Summarise DNS zones in the current project",
    APIVersion:    1,
    MinAPIVersion: 1,
}

func main() {
    plugin.ServeManifest(manifest)
    root := plugin.NewRootCmd("zones", "Summarise DNS zones in the current project")
```

**VO:**
> Here's the whole contract, and the SDK covers each piece.
>
> One. The binary is named `datumctl-zones`. datumctl finds it in its managed
> plugins directory or on your PATH, and `datumctl zones` execs it.
>
> Two. When datumctl runs the binary with `--plugin-manifest`, it prints JSON
> describing itself: name, version, and which plugin API version it speaks.
> `ServeManifest` handles that and exits before Cobra ever runs. It's the
> first line of `main` for a reason.
>
> Three. datumctl sets six environment variables before exec: your org, your
> project, the API host, the plugin API version, the path to datumctl itself,
> and the active session. `plugin.Context()` reads them into a struct, and
> `NewRootCmd` wires them into `--org`, `--project` and `--output` flags with
> the right defaults. You get a Cobra root command back and take it from
> there.

Scroll to the `summary` command. Highlight `plugin.Token()` and the URL.

```go
token, err := plugin.Token()
```

**VO:**
> Four, and this is the one worth pausing on. Notice what's *not* in the
> environment: a token. Plugins don't get a credential handed to them at
> startup. When you need one, `plugin.Token()` shells out to the datumctl
> binary that launched you and asks for a fresh access token from the same
> session. Tokens stay short-lived, refresh stays datumctl's problem, and a
> plugin that dumps its environment doesn't leak a credential.
>
> Then it's a normal HTTP GET against the project's control plane. This is a
> Kubernetes-style API, so the path is the DNS API group under the project's
> control plane. Same URL kubectl would hit.

---

## Beat 2: Build, run, trust (1:45–3:30)

**On screen:**

```
cd plugin
go build -o ../bin/datumctl-zones .
../bin/datumctl-zones --plugin-manifest
```

**VO:**
> Build it. Plain `go build`, output name is the contract: `datumctl-zones`.
> Ask it for its manifest directly and there's the JSON datumctl will read.

```
../bin/datumctl-zones summary
```

Error: `DATUM_CREDENTIALS_HELPER is not set`.

**VO:**
> Run it directly and it refuses. No datumctl, no credentials helper, no
> context. That's correct. It's meant to be run *through* datumctl.

```
export PATH="$PWD/../bin:$PATH"
datumctl zones summary
```

Error: unmanaged plugin that has not been trusted.

**VO:**
> Put it on PATH and try through datumctl. Blocked. datumctl found the
> binary, but it didn't install it, so it won't run it. Anything that can call
> the credentials helper needs your say-so first.

```
datumctl plugin trust zones
datumctl zones context
```

**VO:**
> `plugin trust` records the path and a SHA-256 of the binary. Rebuild it and
> you'll trust it again. Now `zones context` shows exactly what datumctl
> injected: the org and project from our active context, the API host, the
> session, and the path back to datumctl for tokens.

---

## Beat 3: Use it like a real command (3:30–5:00)

**On screen:**

```
datumctl zones summary
```

Expected shape:

```
Project: my-project
Zones:   3
Ready:   3
  - example.com
  - example.net
  - example.org
```

**VO:**
> And there's our command. Three zones, all ready. That was a real
> authenticated call to the project control plane using a token datumctl
> minted a moment ago.

```
datumctl zones summary -o json
datumctl zones summary --project other-project
```

**VO:**
> The flags `NewRootCmd` gave us work as you'd expect. JSON output for
> scripts. Override the project per call, exactly like the built-in commands.

```
datumctl zones summary --project does-not-exist; echo "exit=$?"
```

**VO:**
> Errors propagate. The plugin exits non-zero, datumctl exits non-zero, your
> shell script sees it. No special handling.

```
datumctl zones <TAB>
```

**VO:**
> And tab completion. datumctl forwards completion requests to the plugin, so
> the completion Cobra already generates just works. Nothing to configure.

---

## Closing beat: shipping it (5:00–6:15)

**On screen:**

```
datumctl plugin list
datumctl plugin install datum-cloud/datumctl-dns
```

**VO:**
> Trust is for local development. To ship, you cut a GitHub Release with
> goreleaser: one archive per platform named `datumctl-zones_Darwin_arm64`
> and so on, plus a `checksums.txt`. Then anyone can run
> `datumctl plugin install your-org/datumctl-zones`. datumctl verifies the
> checksum, records it in `plugins.json`, and it shows up in `plugin list`
> as a managed plugin.
>
> Want it installable by name alone? Open a PR to the plugin index at
> `datum-cloud/datumctl-plugins`. That's how `datumctl plugin install dns`
> works.

**On screen, final card:**

```
go get go.datum.net/datumctl/plugin
plugin.ServeManifest(m)
plugin.NewRootCmd(name, short)
plugin.Context()
plugin.Token()
```

**VO:**
> Five SDK calls, one naming rule, and datumctl grows a command your team
> owns. Source for the plugin is linked below.

---

## Cheat sheet for the description / pinned comment

| Step | Command |
|---|---|
| Add the SDK | `go get go.datum.net/datumctl/plugin` |
| Build | `go build -o datumctl-<name> .` |
| Check manifest | `./datumctl-<name> --plugin-manifest` |
| Run locally | put on PATH, then `datumctl plugin trust <name>` |
| Run | `datumctl <name> ...` |
| Revoke | `datumctl plugin untrust <name>` |
| Ship | GitHub Release + `checksums.txt`, then `datumctl plugin install owner/repo` |
| List managed | `datumctl plugin list` |

Env vars datumctl injects: `DATUM_ORG`, `DATUM_PROJECT`, `DATUM_API_HOST`,
`DATUM_PLUGIN_API_VERSION`, `DATUM_CREDENTIALS_HELPER`, `DATUM_SESSION`.

## Presenter notes

- `plugin list` shows **managed** plugins only. A trusted PATH plugin will
  not appear there. The script uses `zones context` and tab completion as the
  "it's really registered" beats instead. Don't promise `plugin list` for it.
- If the `compute` plugin is installed on your machine, `plugin list` in the
  closing beat has something to show. Otherwise it prints "No managed
  plugins installed", which is fine for the narration.
- The `summary` API path is the DNS group under the project control plane.
  It was not exercised against a live API while writing this; confirm it
  returns zones on your project before recording. If the response shape
  differs, the count will still be right but `Ready` may be 0.
- Rebuilding the binary invalidates trust. `demo.sh` rebuilds first, then
  trusts, so this is only a problem if you edit between beats.
- Have three or more zones in the project. One or two makes the summary
  look thin.
- Keep the editor at 90 columns so the SDK calls are visible without
  horizontal scrolling.
