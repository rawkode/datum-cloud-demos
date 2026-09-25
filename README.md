# Datum demos

Short, hands-on videos for Datum Cloud. Each directory holds one video: a
`SCRIPT.md` with narration and on-screen commands, a `demo.sh` driver for the
live recording, and a `README.md` with the brief, prerequisites and reset steps.

| # | Video | Audience | Component | Status |
|---|---|---|---|---|
| 01 | [datumctl feels like kubectl](./01-datumctl-feels-like-kubectl/) | Kubernetes users exploring Datum | datumctl | drafted |
| 02 | [Explore Datum from a terminal UI](./02-explore-datum-from-a-terminal-ui/) | Developers who prefer visual exploration | datumctl console | drafted |
| 03 | [Add cloud commands with plugins](./03-add-cloud-commands-with-plugins/) | Engineers extending their cloud workflow | Datum plugins (DNS first) | drafted |
| 04 | [Make safe changes to Datum](./04-make-safe-changes-to-datum/) | Platform teams using GitOps | explain, diff, dry-run, apply | drafted |
| 05 | [Use the Datum API without handling tokens](./05-use-the-datum-api-without-handling-tokens/) | Developers writing scripts and integrations | datumctl api proxy | drafted |
| 06 | [Ask Datum questions in plain English](./06-ask-datum-questions-in-plain-english/) | Engineers using AI to investigate infrastructure | datumctl ai | drafted |
| 07 | [Give Claude or Cursor access to Datum](./07-give-claude-or-cursor-access-to-datum/) | Developers using MCP-enabled tools | datum-mcp | drafted |
| 08 | [Build a custom datumctl plugin](./08-build-a-custom-datumctl-plugin/) | Go developers extending Datum | Plugin SDK | drafted |
| 09 | [Find out what changed](./09-find-out-what-changed/) | Operators investigating incidents | datumctl activity | drafted |
| 10 | [Deploy a workload to Datum Compute](./10-deploy-a-workload-to-datum-compute/) | Developers deploying containers at the edge | Datum Compute | drafted |

Every video is drafted but none has been run end to end against a live
control plane. Each README lists what is unverified. Before recording any of
them: log in, run its `demo.sh` once, and replace illustrative output in the
script with what the platform actually prints.

Every `demo.sh` sources [`lib/demo.sh`](./lib/demo.sh) for its helpers
(`run`, `pause`, `note`, `prompt`, `type_out`). Change behaviour there, not in
the drivers. The helpers follow two rules so the recording only shows what
the viewer should see:

- Presenter notes (beat names, what to answer at a prompt, which pane to
  switch to) are appended to `$DEMO_NOTES`, default `$TMPDIR/datum-demo-notes`.
  Keep `tail -f "$DEMO_NOTES"` open on a second screen. Nothing the presenter
  needs is printed to the recorded terminal.
- Every wait for Enter is a plain `read -r`. Never use `read -s`: it clears the
  tty ECHO bit, and Ghostty shows its password-input lock on camera whenever
  echo is off.

Two things learned while drafting that apply across videos:

- DNS resources live in `dns.networking.miloapis.com/v1alpha1` (confirmed from
  the dns-operator CRDs). Some datumctl help text still shows an older
  `networking.datumapis.com/v1alpha` example; ignore it.
- `datumctl compute`, `datumctl dns`, `search` and `assistant` are plugins from
  the official `datum-cloud/datumctl-plugins` catalogue, not part of the base
  binary. Videos 03 and 10 install them.

Source of the list: #external-datum, 26 Aug 2026.
