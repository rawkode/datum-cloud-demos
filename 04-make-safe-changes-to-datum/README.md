# 04 · Make safe changes to Datum

| | |
|---|---|
| **Who is it for** | Platform teams using GitOps practices. |
| **What do they learn** | Use explain, diff, dry runs, apply, and describe. |
| **Related Datum component** | [Safe resource changes](https://www.datum.net/docs/datumctl/resources/safe-changes) |

## Files

- `SCRIPT.md` · video script with narration and on-screen commands
- `demo.sh` · live-demo driver
- `manifests/` · the zone and record sets the demo applies, as they'd sit in a Git repo
- `mistakes/dnszone-typo.yaml` · a deliberately invalid manifest for the dry-run beat

## Prerequisites

- `datumctl` installed and logged in (`datumctl login`)
- A project you can create DNS zones in, with the zone class
  `datum-external-global-dns` available. Check with:

  ```sh
  datumctl get dnszoneclasses --project <project>
  ```

  If the class has a different name, change `spec.dnsZoneClassName` in
  `manifests/dnszone.yaml`.
- A domain you control or that is safe to show on camera. The driver
  substitutes it for `example.com` in every manifest.
- macOS `sed` syntax (`sed -i ''`) is used in step 4; on Linux change it to `sed -i` in `demo.sh` and `SCRIPT.md`.
- `diff` on your PATH. For colour, install `colordiff` or `delta` and set
  `DATUMCTL_EXTERNAL_DIFF` (see below).

## Running the demo

```sh
export DEMO_PROJECT=my-project
export DEMO_DOMAIN=safe-changes.rawkode.xyz   # set by ../.envrc; must be unclaimed
export DEMO_DRIFT=1                            # optional, run the edit + drift beat
export DATUMCTL_EXTERNAL_DIFF="colordiff -N -u" # optional, colour diffs
./demo.sh
```

Each command is typed out, then waits for Enter to run, then waits for Enter
to advance. Set `DEMO_TYPE_MS=0` to disable the typing effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

The driver copies `manifests/` and `mistakes/` into a temporary directory with
the domain substituted and runs from there. The files in this folder are never
modified, and the `sed` in step 4 edits the temporary copy.

## The PR pipeline

[`.github/workflows/04-datum-diff.yaml`](../.github/workflows/04-datum-diff.yaml)
runs the preview half of the demo on every pull request that touches
`manifests/`: `datumctl diff` then `datumctl apply --dry-run=server`. It posts
both results as one PR comment, edited in place on each push, and fails the
check if the diff errors or the server rejects the change. It never applies
anything.

It needs, in the repo settings:

- secret `DATUM_SA_CREDENTIALS`: a service account key JSON (portal → IAM →
  service accounts → Datum-managed key), with read access and dry-run
  permission on DNS in the project
- variable `DATUM_PROJECT`: the project to diff against
- variable `DEMO_DOMAIN`: substituted for `example.com`, same as `demo.sh`.
  Set to `safe-changes.rawkode.xyz` so CI and the demo agree.

The diff is against live state, so it only reads as a small change when
live matches `main`. Before filming the PR beat:

```sh
cd 04-make-safe-changes-to-datum
for f in manifests/*.yaml; do sed "s/example\.com/$DEMO_DOMAIN/g" "$f"; echo ---; done \
  | datumctl apply -f -
```

then open (or re-run) a PR that changes the A record IP, the same edit as
step 4. `demo.sh` expects nothing to exist yet, so run its cleanup (see
below) before recording the terminal part.

## Before recording

1. Run through `demo.sh` once end to end. The first `apply` creates a real
   zone and two record sets, and the closing beat deletes them.
2. Confirm `datumctl describe dnsrecordset safe-changes-demo-www` reaches
   `Programmed=True` in reasonable time so the verify beat doesn't stall.
3. Test the external diff tool if you set one. `diff` output is the star of
   this video.
4. If running the drift beat, set `EDITOR` to something quick and set the TTL
   change up in your head so the on-camera edit takes seconds.
5. Terminal at 100 columns or wider so unified diffs don't wrap.

## Reset between takes

The demo deletes everything it creates in the closing beat. If a take is
abandoned part way:

```sh
datumctl delete dnszones,dnsrecordsets -l demo=safe-changes --project <project>
```

Everything the demo creates carries the `demo=safe-changes` label, so that one
command removes it all and nothing else.
