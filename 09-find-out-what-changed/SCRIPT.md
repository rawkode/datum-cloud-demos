# Find out what changed

| | |
|---|---|
| **Audience** | Operators investigating incidents |
| **Outcome** | Find what changed, who changed it, and when |
| **Component** | [datumctl activity](https://www.datum.net/docs/datumctl/activity/overview) |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. One terminal, one project, one incident. |

The whole video is one investigation. A DNS record for a production hostname
started resolving to the wrong address. The audience already knows how to read
a DNS record. What they don't know is that Datum keeps a queryable record of
every change, every actor, and every resulting event, and that one CLI reaches
all of it. Don't explain audit logging as a concept. Show the four questions an
operator asks under pressure and the one command that answers each.

| Question | Command |
|---|---|
| What happened recently? | `datumctl activity feed` |
| What exactly changed on this resource? | `datumctl activity history --diff` |
| Who made the call, and from where? | `datumctl activity audit` |
| What did the platform do about it? | `datumctl activity events` |

---

## Cold open (0:00–0:25)

**On screen:** a terminal running `dig +short www.example.com` twice, the
second answer different from the first. (Pre-record this, or fake it with two
static lines. The point is the wrong IP, not the tool.)

**VO:**
> It's a Tuesday afternoon. Someone pings the channel: "www is pointing at the
> wrong box." Nobody in the room touched it. Nobody in the room *thinks* they
> touched it.
>
> You have three questions, in this order. What changed. Who changed it. And
> what happened next. On Datum, every one of those is a query, and every query
> is one command away.

**Title card:** *Find out what changed*

---

## Beat 1: Start wide with the feed (0:25–1:30)

**On screen:**

```
datumctl activity feed --start-time now-1h
```

**VO:**
> `activity feed` is the place to start when you don't yet know what you're
> looking for. It merges three sources into one timeline: audit log entries,
> resource events, and change history. Every row has a human-readable summary,
> so you can scan it like a chat log.
>
> Time ranges are relative by default. `now-1h`, `now-7d`, or an RFC 3339
> timestamp if you know the window exactly. The default is the last day.

**On screen:**

```
datumctl activity feed --start-time now-1h --change-source human
```

**VO:**
> The first filter I reach for is `--change-source human`. Controllers and
> reconcilers write constantly. People don't. If a record suddenly points
> somewhere new, a person almost certainly did it, so strip the system noise
> out first.

**On screen:**

```
datumctl activity feed --start-time now-1h --change-source human --kind DNSRecordSet
```

**VO:**
> Now narrow by kind. There it is: an update to a DNSRecordSet, a few minutes
> before the report came in, with a named actor. We already know *what* and
> roughly *who*. Let's get exact.

---

## Beat 2: What exactly changed (1:30–2:45)

**On screen:**

```
datumctl activity history dnsrecordsets www-a
```

**VO:**
> `activity history` is per-resource. Give it a type and a name and you get
> every version of that resource's spec, in order, for the last thirty days by
> default.

**On screen:**

```
datumctl activity history dnsrecordsets www-a --diff
```

**VO:**
> Add `--diff` and it renders a unified diff between each consecutive pair of
> versions. This is the moment the room goes quiet. One line removed, one line
> added: the A record content went from the load balancer's address to
> something else entirely.
>
> No guessing from a describe. No comparing against a git repo that may or may
> not match. The platform recorded the before and after.

Pause on the diff hunk. Highlight the changed `content` line.

**VO:**
> If you're thinking "I want that in my incident doc", `-o yaml` gives you the
> full version objects, and `--start-time` and `--end-time` bracket exactly the
> window you care about.

---

## Beat 3: Who did it, and from where (2:45–4:00)

**On screen:**

```
datumctl activity audit --start-time now-1h --resource dnsrecordsets --verb update
```

**VO:**
> The feed told us a person did it. The audit log is the authoritative record:
> timestamp, verb, user, resource, name, and the HTTP status the API returned.
> Filter by resource type and verb, and the list collapses to the one call we
> care about.

**On screen:**

```
datumctl activity audit --start-time now-1h --suggest user.username
```

**VO:**
> Don't know the exact username? `--suggest` is a facet query. It returns the
> distinct values of a field in the window, so you can see every account that
> was active before you filter on one.

**On screen:**

```
datumctl activity audit --start-time now-1h --user alice@example.com
```

**VO:**
> Then filter on that user and see everything they touched, not just the record
> we already know about. Was it a one-off, or the middle of a bigger change?

**On screen:**

```
datumctl activity audit --start-time now-1h \
  --filter='verb == "update" && objectRef.resource == "dnsrecordsets"' \
  -o jsonpath='{range .items[*]}{.requestReceivedTimestamp}{"\t"}{.user.username}{"\t"}{.userAgent}{"\n"}{end}'
```

**VO:**
> When the built-in flags aren't enough, `--filter` takes a CEL expression over
> the raw audit entry. And `-o jsonpath` reaches fields the table doesn't show.
> The user agent, for example. Was this datumctl on a laptop, a CI job, or a
> script someone forgot about? Now you know.

---

## Beat 4: What the platform did about it (4:00–4:50)

**On screen:**

```
datumctl activity events --start-time now-1h --regarding-kind DNSRecordSet --regarding-name www-a
```

**VO:**
> Last question. After the change landed, what did Datum do? `activity events`
> is the platform's own account: state changes and noteworthy occurrences on a
> resource, with a reason and a message. Filter to the record we're
> investigating and read the lifecycle.

**On screen:**

```
datumctl activity events --start-time now-1h --type Warning
```

**VO:**
> Or flip it around. Any warnings in the last hour, across the whole project?
> If the bad address had failed validation you'd see it here. If it didn't,
> that tells you something too: the change was valid, just wrong.

---

## Closing beat: keep watching, keep the record (4:50–5:30)

**On screen:**

```
datumctl activity feed --change-source human --watch
```

**VO:**
> Two things for after the incident. First, `--watch` on the feed streams new
> activity as it happens. Leave it open in a pane while you roll the fix
> forward and you'll see the correction land, and anything else anyone does
> while you're at it.

**On screen:**

```
datumctl activity audit --start-time now-24h --all-pages -o json > incident-$(date +%F).json
```

**VO:**
> Second, `--all-pages` with JSON output pulls the whole window into a file.
> That's your post-mortem attachment, straight from the source of truth.
>
> What changed, who changed it, when, and what happened next. Four commands,
> one CLI, no log aggregator to log into.

**On screen, final card:**

```
datumctl activity feed --change-source human
datumctl activity history <type> <name> --diff
datumctl activity audit --user <who>
datumctl activity events --regarding-name <name>
```

---

## Cheat sheet for the description / pinned comment

| Question | Command |
|---|---|
| What happened in the last hour? | `datumctl activity feed --start-time now-1h` |
| Only changes made by people | `datumctl activity feed --change-source human` |
| Only one resource kind | `datumctl activity feed --kind DNSRecordSet` |
| Full-text search summaries | `datumctl activity feed --search "www-a"` |
| Every version of one resource | `datumctl activity history dnsrecordsets www-a` |
| Diff between versions | `datumctl activity history dnsrecordsets www-a --diff` |
| Who ran updates on a type | `datumctl activity audit --resource dnsrecordsets --verb update` |
| Everything one user did | `datumctl activity audit --user alice@example.com` |
| List active users in window | `datumctl activity audit --suggest user.username` |
| CEL filter over raw audit entries | `datumctl activity audit --filter='verb == "delete"'` |
| Platform events for one resource | `datumctl activity events --regarding-kind DNSRecordSet --regarding-name www-a` |
| Warnings only | `datumctl activity events --type Warning` |
| Stream live | `datumctl activity feed --watch` |
| Export the window | `datumctl activity audit --all-pages -o json > audit.json` |

Time flags accept `now`, `now-1h`, `now-7d`, or RFC 3339. Defaults: last 24h
for audit, events and feed; last 30d for history.

## Presenter notes

- Seed the incident before recording with `DEMO_SEED=1 ./demo.sh` (see
  README). It creates the record with a good address, then applies a "bad"
  update, so history has two versions and the audit log has a real update by
  a real user. Wait a minute or two after seeding so the activity service has
  indexed it before you start Beat 1.
- Do the seeding as a **different user** from the one you record with, if you
  can. The "who did it" beat lands much harder when the answer isn't you.
- If you only have one account, say so on camera and lean on the `userAgent` field
  in the jsonpath beat instead: "same user, different tool" is still a story.
- `--suggest user.username` output is the one command whose exact shape I
  could not verify offline. Run it in rehearsal and adjust the VO if it prints
  something other than a plain list.
- The `dig` cold open is optional. A one-line message screenshot works too.
- Terminal at 120 columns. The audit table has six columns and long emails.
