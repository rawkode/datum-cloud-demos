# Make safe changes to Datum

| | |
|---|---|
| **Audience** | Platform teams using GitOps practices |
| **Outcome** | Use `explain`, `diff`, dry runs, `apply`, and `describe` |
| **Component** | [Safe resource changes](https://www.datum.net/docs/datumctl/resources/safe-changes) |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. A second pane or editor showing the manifest is a nice touch but not required. |

One idea carries this video: **nothing on Datum should surprise you.** The docs say
it plainly: `delete` has no confirmation prompt, and neither `apply` nor `edit`
asks before writing. So the discipline is to preview every change before it
reaches live infrastructure. The video is that discipline, in four steps:
inspect, preview, apply, verify. Then change something and do it again.

Assume the audience already runs GitOps somewhere. Don't sell them on declarative
config. Show them that the kubectl-shaped safety net they rely on is all here.

---

## Cold open (0:00–0:25)

**On screen:** empty terminal, then type one line but do **not** run it.

```
datumctl delete dnszone production
```

**VO:**
> That command has no confirmation prompt. Neither does `apply`. Neither does
> `edit`. Datum treats you like an adult, which is great right up until you
> apply the wrong file to the wrong project.
>
> So this video is about the habit that makes that impossible. Four steps:
> inspect the schema, preview the change, apply it, verify it. If you already
> run GitOps against Kubernetes you'll recognise every one of them.

Hit Ctrl-C to clear the line. **Title card:** *Make safe changes to Datum*

---

## Beat 1: Inspect before you write (0:25–1:30)

**On screen:**

```
datumctl explain dnszones
datumctl explain dnszones.spec
```

**VO:**
> Step one. Before you write a manifest, ask the server what it accepts.
> `explain` pulls the OpenAPI schema from the control plane you're pointed at,
> so it's always the version you're actually deploying to, not whatever the
> docs said last month.
>
> Dot notation walks into nested fields. Here's the spec for a DNS zone: a
> domain name and a zone class.

```
datumctl get dnszoneclasses
datumctl explain dnsrecordsets.spec.records
```

**VO:**
> The zone class is a reference to something that has to exist, so check
> what's available. And for record sets, each entry pairs a record type with a
> type-specific value field. `explain` tells you which fields go together
> before you find out from a validation error.

---

## Beat 2: Preview the change (1:30–3:00)

**On screen:**

```
cat manifests/dnszone.yaml
cat manifests/records.yaml
```

**VO:**
> Here's what we want: one zone and two record sets, in a directory, exactly
> as they'd sit in a Git repo. Now, the two preview tools.

```
datumctl diff -f manifests/
echo "exit: $?"
```

**VO:**
> `diff` fetches the live state of every resource in those files and prints a
> unified diff against what you're about to apply. Nothing exists yet, so it's
> all additions. Note the exit code: zero means no changes, one means there
> are changes, anything higher is an error. That's your CI gate.

```
datumctl apply -f manifests/ --dry-run=server
```

**VO:**
> `diff` tells you *what* would change. `--dry-run=server` asks the API server
> whether it would *accept* the change. The request goes through admission and
> validation and is thrown away before anything is persisted. Both together,
> every time.

**On screen:**

```
cat mistakes/dnszone-typo.yaml
datumctl apply -f mistakes/dnszone-typo.yaml --dry-run=server
```

**VO:**
> Here's why. This file has `domainname`, lower-case n. Strict validation is
> on by default, so the server rejects the unknown field instead of silently
> dropping it and creating a zone with no domain. You find out here, not in
> production.

---

## Beat 3: Apply and verify (3:00–4:00)

**On screen:**

```
datumctl apply -f manifests/
```

**VO:**
> Same command, without the dry run. `apply` is idempotent: it creates what's
> missing and updates what differs, so running it twice is safe.

```
datumctl get dnszones,dnsrecordsets -l demo=safe-changes
datumctl describe dnszone safe-changes-demo
datumctl describe dnsrecordset safe-changes-demo-www
```

**VO:**
> Step four, verify. `get` confirms the objects exist. `describe` is where the
> truth lives: the status conditions. For DNS you're looking for `Accepted`
> and `Programmed`. Accepted means the control plane took it. Programmed means
> it's live on the nameservers. Don't call a change done until the condition
> you care about is True.

---

## Beat 4: Change it, and do it all again (4:00–5:00)

**On screen:** edit the record IP in the file. Use `sed` or an editor pane.

```
sed -i '' 's/203.0.113.10/203.0.113.20/' manifests/records.yaml
datumctl diff -f manifests/
```

**VO:**
> Now the everyday case. Someone changes an IP in a pull request. Run the
> diff and you see exactly one line change, in exactly one resource. That's
> the review comment writing itself.

```
datumctl apply -f manifests/ --dry-run=server && datumctl apply -f manifests/
datumctl describe dnsrecordset safe-changes-demo-www
```

**VO:**
> Dry-run, then apply, then check the condition. The chain with `&&` is the
> whole pipeline step in one line: if validation fails, nothing runs.

**Optional drift beat.** Only if time allows.

```
datumctl edit dnsrecordset safe-changes-demo-www
```

Change the TTL in the editor, save, then:

```
datumctl diff -f manifests/
```

**VO:**
> And the other direction. If someone changes something live, out of band,
> `diff` against your repo shows the drift. Apply from the repo and the live
> state snaps back to what's in Git. That is the GitOps loop, and the tooling
> for it is all in the CLI.

---

**Optional CI beat.** Browser, on a pull request that makes the same IP change.

**On screen:** the PR's checks, then the `datumctl diff` comment on the PR.

**VO:**
> And you don't have to remember to do this. The same two commands run in
> GitHub Actions on every pull request. The diff lands as a comment, the dry
> run gates the check, and the reviewer sees exactly what will change on
> Datum before anyone clicks merge.

---

## Closing beat: clean up, safely (5:00–5:45)

**On screen:**

```
datumctl delete -f manifests/ --dry-run=client
datumctl delete -f manifests/
datumctl get dnszones -l demo=safe-changes
```

**VO:**
> Even teardown gets a preview. `delete --dry-run=client` lists what would go
> without touching the server. Then delete from the same files you applied, so
> you remove exactly what you created and nothing else.
>
> Inspect, preview, apply, verify. Nothing on Datum should surprise you.

**Final card:**

```
datumctl explain <type>.spec
datumctl diff -f ./manifests/
datumctl apply -f ./manifests/ --dry-run=server
datumctl apply -f ./manifests/
datumctl describe <type> <name>
```

---

## Cheat sheet for the description / pinned comment

| Step | Command |
|---|---|
| Inspect the schema | `datumctl explain dnszones.spec` |
| What would change | `datumctl diff -f ./manifests/` (exit 0 none, 1 changes, >1 error) |
| Would the server accept it | `datumctl apply -f ./manifests/ --dry-run=server` |
| Apply | `datumctl apply -f ./manifests/` |
| Verify | `datumctl describe dnsrecordset <name>` and check `Programmed=True` |
| Preview a delete | `datumctl delete -f ./manifests/ --dry-run=client` |
| Detect drift | `datumctl diff -f ./manifests/` after an out-of-band change |
| CI gate | `datumctl diff -f ./manifests/ ; test $? -le 1` |
| Colour diffs | `DATUMCTL_EXTERNAL_DIFF="colordiff -N -u"` (also honours `KUBECTL_EXTERNAL_DIFF`) |

## Presenter notes

- `diff` shells out to the `diff` binary on your PATH. Set
  `DATUMCTL_EXTERNAL_DIFF="colordiff -N -u"` or point it at `delta` for a
  prettier on-camera diff. Test it before recording.
- The zone class `datum-external-global-dns` comes from the DNS skill docs.
  Run `datumctl get dnszoneclasses` in your project first and change the
  manifest if the name differs.
- Pick a `DEMO_DOMAIN` you control or that is clearly reserved. The driver
  substitutes it into the manifests. Don't record with a domain someone else
  owns on screen.
- The typo file is in `mistakes/`, outside `manifests/`, so a directory apply
  never picks it up.
- `Programmed` may take a moment to flip to True. If `describe` shows it
  False on the first run, pause, then run `describe` again rather than
  moving on.
- `datumctl auth can-i` exists but is for kubectl-configured contexts only,
  so it is deliberately not in the video. Mention it in the description for
  teams that also use kubectl against Datum.
- Skip the optional drift beat if the
  video is running long. Beats 1–3 plus the closing stand alone.
