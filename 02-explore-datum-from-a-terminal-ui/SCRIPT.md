# Explore Datum from a terminal UI

| | |
|---|---|
| **Audience** | Developers who prefer visual exploration |
| **Outcome** | Browse resources, inspect YAML, view events, and check platform health |
| **Component** | [datumctl console](https://www.datum.net/docs/datumctl/console) |
| **Target length** | 4–5 minutes |
| **Format** | Terminal screen recording with voice-over. The whole video is one `datumctl console` session; the script is a keystroke walkthrough. |

The idea: **you don't have to memorise resource names or flags to explore Datum.**
`datumctl console` is a k9s-style TUI over the same control plane as `datumctl get`.
Every keystroke below is taken from the console's own help overlay (`?`) and
status bar hints. Keep the narration about *what you're looking at*, not about
the TUI framework. Show the status bar: it always tells the viewer what keys
are live, which is the point.

---

## Cold open (0:00–0:20)

**On screen:** terminal, type and run.

```
datumctl console
```

Let the welcome dashboard land. Hold on it for a beat before speaking.

**VO:**
> Last time we drove Datum with kubectl-style commands. That's great when you
> know what you're looking for. This is for the other days: when you want to
> poke around, see what's there, and get a feel for the platform without
> remembering a single resource name.
>
> One command. That's the console.

**Title card:** *Explore Datum from a terminal UI*

---

## Beat 1: The dashboard and platform health (0:20–1:15)

**On screen:** the welcome dashboard. Point at each region as you talk.

**VO:**
> Top: who you are and which org and project you're in. The console uses the
> same context as every other datumctl command, so if you've already logged in
> and picked a project, you're looking at it right now.
>
> Next: platform health. This is quota. Every governed resource type in the
> project, how much of its allowance you've used, and which ones are near
> the limit. If something's at eighty percent or more, it's flagged here
> before you go looking for it.
>
> Below that, recent activity. Who changed what, in this project, in the last
> seven days.
>
> And at the bottom, quick-jump keys. One letter to land on a resource type.

**On screen:** press `?`.

**VO:**
> If you only remember one key, make it the question mark. Every keybinding,
> grouped by what it does. The status bar at the bottom of the screen shows
> the same thing in short form, and it changes as you move between panes.

Press `?` again to close.

---

## Beat 2: Browse resources (1:15–2:15)

**On screen:** the sidebar is focused on launch. Press `j` a few times to move
through resource types. Note the API group headers.

**VO:**
> The sidebar lists every resource type on this control plane, grouped by API
> group. This isn't a hard-coded menu. It's discovered from the server, the
> same list `datumctl api-resources` gives you. New platform feature, new
> entry in the sidebar.

**On screen:** move to `dnszones` and press `Enter`. The table loads.

**VO:**
> Enter opens the table. Name, status, age: the same columns as `get`.
>
> A quota banner sits above the table when the type is governed, so you can
> see headroom for exactly the thing you're creating.

**On screen:** press `/`, type a partial zone name, press `Enter`.

**VO:**
> Slash filters by name, live. Esc clears it.

**On screen:** press `Esc` to go back to the dashboard, then press `z`.

**VO:**
> And those quick-jump keys from the dashboard. `z` for DNS, `p` for
> projects, `w` for workloads, `g` for gateways. Muscle memory in about an
> hour.

---

## Beat 3: Inspect a resource (2:15–3:30)

**On screen:** in the DNS zones table, move to a row with `j` / `k`, press `d`.

**VO:**
> `d` describes the selected resource. Same output as `datumctl describe`, in
> a scrollable pane. Now the status bar changes, because in the detail view
> you get four sub-views.

**On screen:** press `y`.

**VO:**
> `y` toggles the raw YAML. This is the object as the API server holds it,
> which is what you'd paste into a manifest or diff against Git.

**On screen:** press `C` (capital).

**VO:**
> Capital `C` is the conditions table. Every `.status.conditions` entry with
> its type, status, reason and message. If a zone isn't becoming ready, the
> answer is on this screen.

**On screen:** press `E` (capital).

**VO:**
> Capital `E` is events. They're fetched on demand and the status line
> shows how old the fetch is. `r` refreshes.

**On screen:** press `H` (capital), then `]` and `[` to step through revisions.

**VO:**
> And capital `H` opens change history: each revision of this object, with
> a diff between them. Square brackets step forward and back. Who changed
> what, and exactly which lines. We'll do a whole video on this later.

Press `Esc` twice to return to the table.

---

## Beat 4: Dashboards and context (3:30–4:15)

**On screen:** press `3`.

**VO:**
> Number `3` is the quota dashboard, from anywhere. This is the platform
> health panel in full: every allowance bucket, grouped by scope, with usage
> bars. `t` flips to the raw table, `s` regroups. `3` again takes you back
> to where you were.

**On screen:** press `3` to return, then `4`.

**VO:**
> Number `4` is the activity dashboard: recent human activity for the
> project. `Esc` returns.

**On screen:** press `Esc`, then `c`. The context switcher appears.

**VO:**
> `c` switches organisation or project without leaving the console. Pick
> one, Enter, and the sidebar, dashboard, and quota all reload for the new
> scope.

Switch to the alternate context and back so the header visibly changes.

---

## Closing beat (4:15–4:45)

**On screen:** dashboard. Press `q`.

**VO:**
> Same control plane, same resources, same context as the CLI, with none of
> the typing. When you know what you want, use `datumctl get`. When you're
> finding out what you want, open the console.
>
> There's also an AI chat pane behind `a`, but that's its own video.

**On screen, final card:**

```
datumctl console

?   help           /   filter         d   describe
y   yaml           C   conditions     E   events
H   history        3   quota          4   activity
c   switch ctx     q   quit
```

---

## Cheat sheet for the description / pinned comment

| Key | Where | What |
|---|---|---|
| `?` | anywhere | keybind reference |
| `j` / `k`, arrows | anywhere | move |
| `Tab` / `Shift+Tab` | sidebar ↔ table | switch pane |
| `Enter` | sidebar | open resource type |
| `/` | table | filter by name |
| `d` or `Enter` | table | describe selected resource |
| `y` | detail | toggle raw YAML |
| `C` | detail | toggle conditions table |
| `E` | detail | toggle events |
| `A` | detail | per-resource activity log |
| `H` | detail | change history with diffs (`[` / `]` step revisions) |
| `3` | anywhere | quota dashboard (`t` table, `s` group) |
| `4` | anywhere | activity dashboard |
| `c` | anywhere | switch org / project |
| `r` | anywhere | refresh |
| `a` | anywhere | AI chat |
| `Esc` | anywhere | back / home |
| `q` | anywhere | quit |
| `n` `b` `w` `p` `g` `v` `i` `z` | dashboard | quick-jump to a resource type |

## Presenter notes

- Record at 120 columns × 40 rows or larger. The dashboard hides the quota
  bars below 80 columns and the activity and quick-jump sections below 18
  rows, and the video needs all of them.
- Log in and pick the project context **before** launching. If you launch
  logged out you get a welcome screen with `[l] login` instead of the
  dashboard, which is a different video.
- Use `--read-only` for the recording. It puts a READ-ONLY badge in the
  header and disables `x` (delete), so a mis-key can't wreck the demo
  project.
- Have a DNS zone with at least two revisions so `H` has a diff to show.
  Editing a label with `datumctl edit` before recording is enough.
- Have at least one governed resource type close to its quota so the
  platform health section shows something other than "all clear".
- Two contexts, so `c` visibly changes the header.
- The events sub-view fetches on demand. Press `E` once off-camera first if
  the API is slow, then the on-camera press will be instant from cache.
