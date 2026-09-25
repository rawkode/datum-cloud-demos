# Add cloud commands with plugins

| | |
|---|---|
| **Audience** | Engineers extending their cloud workflow |
| **Outcome** | Search, install, list, and use Datum plugins, starting with DNS |
| **Component** | [Datum plugins](https://www.datum.net/docs/datumctl/plugins/using-plugins) |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. Optional split screen for the krew comparison beat. |

The idea this video sells: **datumctl is small on purpose, and you grow it
yourself.** Every Datum service ships its own commands as a plugin. The CLI
finds them, installs them, verifies them, and runs them as if they were
built in. Kubernetes users will recognise the shape from kubectl plugins and
krew. Don't dwell on the mechanics of how plugins are built. That's video 08.
This one is the user's side: find, install, use, keep up to date.

---

## Cold open (0:00–0:30)

**On screen:** empty terminal, type one line.

```
datumctl dns
```

Expected shape (interactive terminal):

```
To use "dns" you need to install the dns plugin.
Manage DNS zones and records on Datum Cloud

Would you like to install it now? [y/N]
```

Press `N`.

**VO:**
> Fresh install of datumctl. I ask for DNS and it doesn't have it. But it
> knows exactly where to get it.
>
> That's the plugin system. The core CLI ships with the kubectl-shaped verbs,
> `get`, `describe`, `apply`. Everything service-specific, DNS, compute,
> search, lives in a plugin. You add the ones you need and skip the rest.
>
> Let's do it properly. Find it, install it, use it.

**Title card:** *Add cloud commands with plugins*

---

## Beat 1: Find plugins (0:30–1:30)

**On screen, optionally split with kubectl on the left:**

```
kubectl krew search      |   datumctl plugin search
kubectl krew install X   |   datumctl plugin install X
kubectl krew list        |   datumctl plugin list
kubectl X                |   datumctl X
```

**VO:**
> If you've used krew, you already know the model. A plugin is a binary
> named `datumctl-something`. A catalog tells the CLI where to fetch it and
> what its checksum should be. The difference is that Datum's catalog is
> built in. Nothing to bootstrap.

Run the datumctl side live:

```
datumctl plugin search
```

Expected shape:

```
NAME        INDEX   VERSION   TRUST      DESCRIPTION
assistant   datum   v0.0.2    official   Chat with Patch, the Datum Cloud assistant, and browse your conversation history
compute     datum   v0.8.0    official   Deploy and manage containerized workloads on Datum Cloud
dns         datum   v0.7.4    official   Manage DNS zones and records on Datum Cloud
search      datum   v0.8.0    official   Search for resources across the platform by kind, name, and project scope
```

**VO:**
> `plugin search` with no query lists everything in every catalog you've
> registered. Four columns matter. The name you'll install by. Which catalog
> it came from. The version. And the trust badge: `official` means Datum's
> curated catalog, `third-party` means one you added yourself.

```
datumctl plugin search dns
```

**VO:**
> Pass a word to filter by name or description. There's also `plugin browse`
> for an interactive picker with descriptions and an install button, if you'd
> rather scroll than type.

---

## Beat 2: Install and check (1:30–2:45)

**On screen:**

```
datumctl plugin install dns
```

Expected shape:

```
Installed dns v0.7.4 from datum  [official]
```

**VO:**
> Install by name. The CLI resolves it against the official catalog, downloads
> the archive for your OS and architecture over HTTPS, checks the SHA256
> against the catalog manifest, asks the binary for its manifest to confirm
> it's compatible with this version of datumctl, and drops it into
> `~/.datumctl/plugins`. One line of output because nothing went wrong.
>
> You can pin a version with `dns@v0.7.4`, or skip the catalog entirely and
> install straight from a GitHub release with `owner/repo`. Same checksum
> verification either way, using the release's `checksums.txt`.

```
datumctl plugin list
```

Expected shape:

```
NAME   INDEX   VERSION   TRUST      DESCRIPTION                                   STATUS
dns    datum   v0.7.4    official   Manage DNS zones and records on Datum Cloud   ok
```

**VO:**
> `plugin list` is your inventory. The status column is the one to watch.
> `ok` means installed and compatible. `update` means the catalog has a newer
> version. An exclamation mark means it was built for a different datumctl.

```
datumctl dns version
datumctl dns --help
```

Expected shape for `version`:

```
datumctl-dns v0.7.4 (DNS API dns.networking.miloapis.com/v1alpha1)
```

**VO:**
> And now `datumctl dns` just works. No new binary to remember, no new
> config. The plugin appears under the datumctl namespace, and its help text
> reads like the rest of the CLI because it's built with the same SDK.
>
> Tab completion works too. datumctl forwards completion requests to the
> plugin, so `datumctl dns zone` tab gives you the plugin's subcommands.

**On screen:** type `datumctl dns zone ` and hit tab to show the completions.

---

## Beat 3: Use the DNS plugin (2:45–4:30)

**On screen:**

```
datumctl whoami
datumctl dns zone list
```

**VO:**
> Here's the part that makes plugins more than a convenience. I haven't told
> the DNS plugin which organisation or project I'm in. It already knows.
>
> When datumctl runs a plugin it passes the active context in the environment,
> and it gives the plugin a way to fetch a short-lived token on demand. The
> token itself is never put in an environment variable. So the plugin sees
> what you see, with the credentials you already have, and nothing more.

```
datumctl dns zone create example-demo.com
```

**VO:**
> Create a zone. The plugin waits for nameservers to be assigned and prints
> them, along with the next steps. If you've done this through the DNSZone
> resource with `datumctl apply`, this is the same object underneath, with a
> friendlier front door.

```
datumctl dns record create example-demo.com www A 203.0.113.10
datumctl dns record create example-demo.com @ TXT "v=spf1 -all"
datumctl dns record list example-demo.com
```

**VO:**
> Records are one line each, in the order you'd write them in a zone file.
> Name, type, value. Structured types like MX and SRV take named flags, or
> you can paste the presentation format straight from another provider.
>
> `record list` flattens everything back out, one row per value, even though
> the API stores them grouped by name and type. The plugin hides that for you.

```
datumctl dns zone describe example-demo.com
datumctl dns zone nameservers example-demo.com --check
```

**VO:**
> `describe` shows delegation state. `nameservers --check` goes further and
> actually queries the public DNS to tell you whether your registrar is
> pointed at Datum yet. That's the kind of thing a plugin can do that a
> generic `get` can't.

```
datumctl dns zone list -o json | head -20
```

**VO:**
> And because every plugin uses the same output flags, `-o json` and
> `-o yaml` are there when you need to script it.

---

## Beat 4: Keep plugins current (4:30–5:15)

**On screen:**

```
datumctl plugin upgrade dns
```

**VO:**
> Upgrading re-runs the install flow against the latest catalog version, with
> the same checksum and compatibility checks.

```
datumctl plugin install
```

**VO:**
> `plugin install` with no arguments reinstalls everything recorded in your
> plugin manifest at the versions you had. Clone your dotfiles onto a new
> machine, run this once, and you're back where you were.

```
datumctl plugin index list
```

**VO:**
> Catalogs are pluggable too. The `datum` catalog is always there. Your
> platform team can publish an internal one, register it with
> `plugin index add`, and its plugins show up in search alongside Datum's,
> badged as third-party so nobody confuses the two.
>
> One more thing on trust. If you build a plugin yourself and drop it on your
> PATH, datumctl will refuse to run it until you say `plugin trust`. It
> records the path and a fingerprint of the binary. If the binary changes,
> trust is revoked until you re-approve it.

```
datumctl plugin remove dns
```

**VO:**
> And removal deletes the binary and forgets it. Clean.

---

## Closing beat (5:15–5:45)

**On screen, final card:**

```
datumctl plugin search
datumctl plugin install dns
datumctl plugin list
datumctl dns zone list
datumctl plugin upgrade dns
```

**VO:**
> Search, install, list, use, upgrade. The core CLI stays small. The
> services you use grow it. And every plugin inherits your login and your
> context, so the first command after install is a real one.
>
> If you want to write a plugin of your own, the SDK video covers it. Links
> below.

---

## Cheat sheet for the description / pinned comment

| kubectl + krew | datumctl |
|---|---|
| `kubectl krew search` | `datumctl plugin search [query]` |
| `kubectl krew install NAME` | `datumctl plugin install NAME` |
| `kubectl krew install NAME@vX` | `datumctl plugin install NAME@vX` |
| `kubectl krew list` | `datumctl plugin list` |
| `kubectl krew upgrade NAME` | `datumctl plugin upgrade NAME` |
| `kubectl krew uninstall NAME` | `datumctl plugin remove NAME` |
| `kubectl krew index add` | `datumctl plugin index add NAME OWNER/REPO` |
| `kubectl NAME ...` | `datumctl NAME ...` |
| *(n/a)* | `datumctl plugin browse` |
| *(n/a)* | `datumctl plugin trust NAME` |
| *(n/a)* | `datumctl plugin install` (restore all) |

Official plugins today: `assistant`, `compute`, `dns`, `search`.
Catalog: https://github.com/datum-cloud/datumctl-plugins

## Presenter notes

- Run `datumctl plugin remove dns` before recording so the cold open prompt
  and the install beat are real.
- Answer `N` at the cold-open prompt. Saying `y` installs it and skips the
  search beat, which is the whole point of Beat 1.
- `plugin search`, `plugin install`, `plugin list` and `datumctl dns version`
  all work without a login. Everything in Beat 3 needs an active project
  context. Check `datumctl whoami` first.
- Use a domain you control or an obviously fake one for `zone create`. The
  zone is real and billable-looking in the console. Delete it after.
- `nameservers --check` queries public DNS and will report "not delegated"
  for a fresh zone. That's fine, say so on camera. It's the honest output.
- Widen the terminal to 130 columns. The search table is wide.
- Keep the trust story to narration. Demonstrating an unmanaged plugin means
  building one, and that's video 08.
