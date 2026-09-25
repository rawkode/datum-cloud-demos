# Give Claude or Cursor access to Datum

| | |
|---|---|
| **Audience** | Developers using MCP-enabled tools |
| **Outcome** | Install, configure, and use datum-mcp for resource investigation |
| **Component** | [datum-mcp](https://github.com/datum-cloud/datum-mcp) |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. Claude Code is the on-camera client because it records cleanly in a terminal. Cursor and Claude Desktop get a config-file beat. |

The idea: **your AI tool already knows how to ask questions. datum-mcp gives it
the answers.** One binary, one config block, and Claude or Cursor can list,
inspect, and explain your Datum resources in plain language. The audience
knows what MCP is. Don't explain the protocol. Show the install, the config,
the first-run login, and three real investigations. Then draw the line
clearly: the server has write tools, and the client's permission prompt is the
boundary.

---

## Cold open (0:00–0:25)

**On screen:** a Claude Code session. Type one prompt.

```
> Which of my DNS zones aren't ready yet, and why?
```

Claude calls the `dnszones` tool, reads the status conditions, and answers.

**VO:**
> That's Claude Code, and that's a real answer from a real Datum project.
> No copy-pasting YAML into a chat window. No API tokens in a config file.
> Claude asked Datum directly.
>
> The piece in the middle is datum-mcp, a Model Context Protocol server for
> Datum Cloud. Let's set it up from nothing and see what it can do.

**Title card:** *Give Claude or Cursor access to Datum*

---

## Beat 1: Install (0:25–1:00)

**On screen:**

```
curl -fsSL https://github.com/datum-cloud/datum-mcp/releases/latest/download/install.sh | sh
which datum-mcp
```

**VO:**
> One installer. It detects your platform, downloads the binary, and drops it
> somewhere on your PATH, `/usr/local/bin` if it can, `~/.local/bin` if not.
> Prebuilt binaries for macOS, Linux and Windows are on the releases page if
> you'd rather do it by hand.
>
> It speaks MCP over stdio. Your editor or agent launches it as a subprocess
> and they talk over stdin and stdout. Nothing listens on a port.

---

## Beat 2: Register with your client (1:00–2:00)

**On screen:**

```
claude mcp add --scope user datum-mcp -- datum-mcp
claude mcp list
```

**VO:**
> Claude Code registers servers from the command line. Name it, give it the
> command, done. `--scope user` makes it available in every project on this
> machine.

**On screen, show the two config files side by side:**

```
cat config/claude-desktop.json
cat config/cursor.mcp.json
```

Expected shape:

```json
{
  "mcpServers": {
    "datum-mcp": {
      "command": "datum-mcp",
      "args": []
    }
  }
}
```

**VO:**
> Claude Desktop and Cursor use a JSON file instead. It's the same three
> lines: a name, a command, no arguments. Cursor also has a one-click install
> button in the datum-mcp README, which writes exactly this block for you.
>
> Windows users: put the full path to the `.exe` in `command`. Everything
> else is identical.

---

## Beat 3: First run and login (2:00–3:00)

**On screen:**

```
claude
```

```
> Which Datum organisations am I a member of?
```

Browser opens for OAuth. Sign in. Return to the terminal; Claude lists the
organisations.

**VO:**
> First use triggers login. datum-mcp opens your browser, you sign in to
> Datum with OAuth and PKCE, and the refresh token goes into your OS keychain.
> That's it. Every later call reuses or refreshes that token silently.
>
> Notice what didn't happen. No API key was generated, nothing was pasted
> into a config file, nothing is sitting in plain text on disk.

**On screen:**

```
> Set my active organisation to <org>, then list its projects and set <project> as active.
```

**VO:**
> The server keeps an active org and project, the same idea as a context in
> datumctl. Set them once in conversation and every later question is scoped
> to that project. Or set `DATUM_ORG` in the server's environment and skip
> the first step.

---

## Beat 4: Investigate (3:00–4:45)

Three prompts, each showing a different tool. Let Claude's tool calls stay
visible on screen so the audience sees which tool answered.

**On screen:**

```
> List the DNS zones in this project and flag any that aren't ready.
```

**VO:**
> `dnszones`, action `list`. Claude reads the status conditions and
> summarises. This is the everyday one: state of the world, in a sentence.

**On screen:**

```
> Show me every record set for <zone> and check whether the apex has both A and AAAA records.
```

**VO:**
> `dnsrecordsets`. Now Claude is doing the tedious part, reading through the
> records and applying a check you described in English.

**On screen:**

```
> What fields does a Datum HTTPProxy spec support, and which are required?
```

**VO:**
> This one's my favourite. The `apis` tool pulls the OpenAPI schema straight
> from the control plane. Claude explains the resource from the real
> definition, not from memory. If the platform version changes, so does the
> answer.

**On screen:**

```
> Which HTTP proxies route to backends that don't have a traffic protection policy?
```

**VO:**
> And it chains. `httpproxies`, then `trafficprotectionpolicies`, then a join
> Claude works out for itself. That's the kind of question you'd otherwise
> answer with three `get` commands and a jq pipeline.

---

## Closing beat: where the line is (4:45–5:45)

**On screen:**

```
> Add a TXT record "hello" to the apex of <zone>.
```

Claude Code shows its permission prompt for the `dnsrecordsets` tool call.
Pause on it. Decline.

**VO:**
> Be clear-eyed about this. datum-mcp is not read-only. Domains, proxies,
> routes, gateways, policies, zones and records all have create, update and
> delete actions.
>
> The guard is your client. Claude Code asks before every tool call it hasn't
> been told to trust. Cursor does the same. So the workflow is: let the agent
> investigate freely, and read the prompt carefully when it wants to write.
>
> If you're wiring this into automation and want it locked down, the same
> permission model applies, and you can hand the server a scoped token via
> `DATUM_TOKEN` instead of a browser login.

**On screen, final card:**

```
curl -fsSL .../install.sh | sh
claude mcp add datum-mcp -- datum-mcp
> Which of my DNS zones aren't ready yet?
```

**VO:**
> Install, register, ask. Your AI tool can now see Datum. What it's allowed
> to change is still up to you.

---

## Cheat sheet for the description / pinned comment

| Task | How |
|---|---|
| Install | `curl -fsSL https://github.com/datum-cloud/datum-mcp/releases/latest/download/install.sh \| sh` |
| Claude Code | `claude mcp add --scope user datum-mcp -- datum-mcp` |
| Claude Desktop / Cursor | `{"datum-mcp": {"command": "datum-mcp", "args": []}}` under `mcpServers` |
| Login | Automatic on first tool call (browser OAuth, token in keychain) |
| Scope to a project | Ask the agent to set the active org and project, or set `DATUM_ORG` |
| Headless auth | `DATUM_TOKEN=<bearer>` in the server's environment |
| Staging | `DATUM_AUTH_HOSTNAME=auth.staging.env.datum.net` |

Tools exposed: `organizationmemberships`, `users`, `projects`, `domains`,
`httpproxies`, `httproutes`, `gateways`, `trafficprotectionpolicies`,
`dnszones`, `dnsrecordsets`, `dnszoneclasses`, `apis`.

## Presenter notes

- Do the OAuth login **off camera** first so the keychain entry exists, then
  delete it and log in again on camera. Otherwise the browser round trip
  eats thirty seconds of dead air.
- Have a project with at least two DNS zones, one of which is not ready
  (a zone whose nameservers haven't been delegated works), a couple of
  record sets, and at least one HTTPProxy. The investigation beat is only as
  good as the data.
- Keep Claude Code's tool-call output expanded so the audience sees the tool
  name and action. That's the whole point of the beat.
- The closing write prompt must be one you're comfortable declining on
  camera. Do not approve it by accident.
- If Claude Code is not your daily client, swap Beat 2 to show your own
  config file. The JSON is identical across clients.
