# 10 · Deploy a workload to Datum Compute

| | |
|---|---|
| **Who is it for** | Developers deploying containerised workloads at the edge. |
| **What do they learn** | Deploy an image, configure location and replicas, and watch the rollout. |
| **Related Datum component** | [Datum Compute](https://github.com/datum-cloud/compute) and `datumctl compute deploy`. |

## Files

- `SCRIPT.md` · video script with narration and on-screen commands
- `demo.sh` · live-demo driver
- `manifests/hello.yaml` · manifest form of the workload, for the closing beat

## How `datumctl compute` is delivered

`compute` is not in the base datumctl binary. It is a plugin in the official
catalogue, published from the [compute](https://github.com/datum-cloud/compute)
repo (`cmd/datumctl-compute`) and installed with:

```sh
datumctl plugin install compute
```

Version at time of writing: v0.8.0 (released 16 Sep 2026). The plugin reads
the active datumctl session and project, so no separate auth.

## What is verified and what is not

**Verified** against the installed plugin's `--help` output:

- every command and flag used in `SCRIPT.md` and `demo.sh`
  (`deploy`, `workloads`, `workloads describe`, `instances`, `scale`,
  `rollout`, `restart`, `destroy`, `access`, `quota`, `build`)
- `--city`, `--location`, `--location-selector`, `--min`, `--http-port`,
  `--no-http`, `--runtime-class`, `--network`, `-f`, `-y` on `deploy`
- `datumctl plugin search compute` returns the plugin from the `datum` index

**Not verified** because this machine has no active Datum session:

- the exact output tables. The blocks in `SCRIPT.md` marked *illustrative*
  come from the plugin's design docs (`docs/enhancements/datumctl-compute-dx.md`
  and `datumctl-compute-urls.md` in the compute repo) and should match v0.8.0
  closely, but capture the real thing on the dry run.
- the image `ghcr.io/datum-cloud/hello:latest` is a **placeholder**. Nothing
  by that name has been confirmed to exist. Substitute a real image.
- city codes `DFW` and `IAD` are from the plugin's own examples. Check which
  locations your project has before recording.
- `manifests/hello.yaml` follows the documented `Workload` schema for
  placements and scale settings, but the container template fields are
  reconstructed from the compute repo's `workload-create` skill, not from a
  captured object. Replace it with the output of
  `datumctl get workload hello -o yaml` after your first flag-based deploy.

## Prerequisites

- `datumctl` installed and logged in, with a project context set
- Compute enabled for the project: `datumctl compute access` should report
  it granted. If not, `datumctl compute access request` files the request
  and Datum approves it manually. Allow time for this.
- Quota for at least four instances (two cities, two replicas each) shown by
  `datumctl compute quota`. Quota is granted by Datum and cannot be
  self-served.
- A fully qualified OCI image that serves HTTP on a known port and runs on
  Datum. If it is your own image, build it with `datumctl compute build`
  (with `--analyze`) so known incompatibilities are caught before recording.
- `jq` if you set `DEMO_OPEN=1`, so the driver can pull the URL out of
  `workloads -o json`.

## Running the demo

```sh
export DEMO_PROJECT=my-project
export DEMO_IMAGE=ghcr.io/you/hello:1.0.0     # must serve HTTP on DEMO_PORT
export DEMO_CITY=DFW                          # optional
export DEMO_CITY2=IAD                         # optional; set empty to skip the spread beat
export DEMO_PORT=8080                         # optional
export DEMO_OPEN=1                            # optional; open the URL after deploy
export DEMO_DESTROY=1                         # optional; 0 leaves the workload running
./demo.sh
```

Each command is typed out, then waits for Enter to run, then waits for Enter
to advance. Set `DEMO_TYPE_MS=0` to disable the typing effect.

Stage directions (beat names, what to answer at prompts, when to switch panes)
never go to the recorded terminal. The driver appends them to `$DEMO_NOTES`
(default `$TMPDIR/datum-demo-notes`); keep `tail -f "$DEMO_NOTES"` open on a
second screen while recording.

## Before recording

1. Run the whole driver once off-camera. This confirms access, quota, the
   image, and the location names, and warms whatever image caching exists so
   the on-camera rollout is quick.
2. Capture the real output of `deploy`, `workloads describe`, and `rollout`
   and update the illustrative blocks in `SCRIPT.md` if columns differ.
3. Run `datumctl get workload <name> -o yaml` after that first deploy and
   replace `manifests/hello.yaml` with the real spec, keeping `minReplicas: 2`
   so the manifest beat shows a diff.
4. Destroy the workload so the on-camera deploy says "creating", not
   "updating".
5. Terminal at 120 columns or wider.

## Reset between takes

```sh
datumctl compute destroy <name> -y
```

Removes the workload, its instances, and its URL. The plugin install persists
between takes; remove it with `datumctl plugin remove compute` only if you
want the install beat to show a fresh install on camera.
