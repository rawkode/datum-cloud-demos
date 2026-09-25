# 09 · Find out what changed

| | |
|---|---|
| **Who is it for** | Operators investigating incidents. |
| **What do they learn** | Find what changed, who changed it, and when. |
| **Related Datum component** | [datumctl activity](https://www.datum.net/docs/datumctl/activity/overview) |

Video script and live-demo driver. See [SCRIPT.md](./SCRIPT.md) for the
narration and [demo.sh](./demo.sh) for the command sequence.

## Files

- `SCRIPT.md` · video script with narration and on-screen commands
- `demo.sh` · live-demo driver, with a seed mode that stages the incident

## Prerequisites

- `datumctl` installed and logged in (`datumctl login`)
- A project with at least one DNSZone. The seed step creates a DNSRecordSet
  in it and then changes it, so history has two versions to diff.
- Ideally, **two accounts**: one to seed the "bad" change, one to record the
  investigation with. The "who did it" beat is far stronger when the answer
  isn't the presenter. Use `datumctl auth switch <email>` to move between them.

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

## Staging the incident

Run the seed mode as the account you want to be "the culprit":

```sh
export DEMO_PROJECT=my-project
export DEMO_ZONE=example-com
DEMO_SEED=1 ./demo.sh
```

This applies a DNSRecordSet named `www-a` pointing at `203.0.113.10`, waits
20 seconds, then applies it again pointing at `198.51.100.7`. Override the
addresses with `GOOD_IP` and `BAD_IP`, and the record name with `DEMO_RECORD`.

Give the activity service a minute or two to index before you start recording.
If `datumctl activity feed --start-time now-10m` doesn't show the update yet,
wait a little longer.

## Running the demo

Switch to the presenting account, then:

```sh
export DEMO_PROJECT=my-project
export DEMO_RECORD=www-a          # optional, default www-a
export DEMO_ACTOR=alice@example.com   # optional, otherwise discovered from the audit log
export DEMO_WINDOW=now-1h         # optional, widen if seeding was a while ago
export DEMO_WATCH=1               # optional, run the --watch beat (Ctrl-C to leave it)
./demo.sh
```

Each command is typed out, then waits for Enter to run, then waits for Enter
to advance. Set `DEMO_TYPE_MS=0` to disable the typing effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

## Before recording

1. Seed, wait, then rehearse the whole driver once. Confirm the `--diff` beat
   shows exactly one changed line, and that the audit beat names the seeding
   account.
2. Check the output shape of `--suggest user.username`. That is the one
   command not verified against a live control plane while writing this.
3. Terminal at 120 columns or wider. The audit table has six columns and
   email addresses are long.
4. Remove any `incident-*.json` files left in the directory from rehearsal.

## Reset between takes

The activity log is append-only, so you cannot un-record the seed. Between
takes, either widen `DEMO_WINDOW` so the original seed is still in range, or
re-seed with a new record name:

```sh
DEMO_RECORD=www-b DEMO_SEED=1 ./demo.sh
```

To clean up after the shoot:

```sh
datumctl delete dnsrecordset www-a --project my-project
rm -f incident-*.json
```
