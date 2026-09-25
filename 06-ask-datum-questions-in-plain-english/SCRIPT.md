# Ask Datum questions in plain English

| | |
|---|---|
| **Audience** | Engineers using AI to investigate infrastructure |
| **Outcome** | Query resources with natural language and understand approval boundaries |
| **Component** | [datumctl ai](https://www.datum.net/docs/datumctl/ai/assistant) |
| **Target length** | 5–6 minutes |
| **Format** | Terminal screen recording with voice-over. |

The whole video rests on one idea: **the assistant reads freely, but never writes
without you saying yes.** Every question on camera is chosen to move one step
closer to a mutation, so the audience sees exactly where the line is and what
crossing it looks like. Don't oversell the model. Sell the boundary.

---

## Cold open (0:00–0:25)

**On screen:** empty terminal, then type one line.

```
datumctl ai "which of my DNS zones aren't ready yet?"
```

Let it run. The spinner ticks, a tool call or two happen, and an answer appears.

**VO:**
> That's a question I'd normally answer with three commands and a JSONPath
> expression I'd have to look up. Instead I asked it in English.
>
> `datumctl ai` is a natural-language front end on the same API every other
> datumctl command uses. It can list, inspect, validate, apply and delete. The
> interesting part isn't that it can do those things. It's that it will only
> do half of them without asking you first.
>
> Five minutes: set it up, ask it things, then push it over the line and watch
> it stop.

**Title card:** *Ask Datum questions in plain English*

---

## Beat 1: Setup (0:25–1:15)

**On screen:**

```
datumctl whoami
datumctl ai config set anthropic_api_key sk-ant-...
datumctl ai config set project my-project
datumctl ai config show
```

Use a redacted or throwaway key on camera. `config show` redacts keys in its
own output, so it is safe to leave in the recording.

**VO:**
> Two prerequisites. You're logged in to Datum, and you have an API key for
> one of the supported model providers: Anthropic, OpenAI or Gemini.
>
> Save the key and a default project once with `ai config set`. The assistant
> picks a provider from whichever key it finds, and you can override the model
> per call with `--model`. From here on, no flags.
>
> The config lives in a small YAML file under your config directory. `config
> show` prints it with the key redacted.

---

## Beat 2: Read-only questions (1:15–2:45)

**On screen:**

```
datumctl ai "what kinds of resources can I manage in this project?"
```

**VO:**
> Start broad. Behind that answer the assistant called one tool,
> `list_resource_types`, which is the same discovery call `datumctl
> api-resources` makes. Nothing it did here touched anything.

```
datumctl ai "list my DNS zones and tell me which ones have a problem"
```

**VO:**
> Now a real investigation question. It lists the zones, reads their status
> conditions, and summarises. This is `get` plus `describe` plus the reading
> you'd do with your eyes, and it's still entirely read-only.

```
datumctl ai "show me the full spec of the example-com zone as YAML"
```

**VO:**
> It'll happily hand you the raw object too. Ask for YAML and you get the
> same document `datumctl get -o yaml` would give you.
>
> Here's the rule the assistant runs on. Eight tools. Six of them read:
> discover types, fetch a schema, list, get, validate a manifest, and switch
> context. Those run immediately. The other two, apply and delete, never run
> without a confirmation prompt. There is no flag to turn that off.

**On screen:** the tool table from the docs, or just say it.

---

## Beat 3: Interactive session and the approval boundary (2:45–4:30)

**On screen:**

```
datumctl ai
```

The banner prints. It introduces itself as Patch and shows the resolved
organisation, project and namespace.

**VO:**
> Drop the question and you get a session. It keeps context, so follow-ups
> work the way you'd expect.

Type at the prompt:

```
> which DNS zone was created most recently?
```

```
> add a TXT record to it called _demo with the value "hello from patch"
```

**VO:**
> And now we cross the line. This needs a write, so the assistant builds the
> manifest, validates it server-side, and then stops.

Pause on the preview block. It looks like this:

```
--- Proposed action ---
Tool:    apply_manifest
Details:
{
  "yaml": "apiVersion: dns.networking.miloapis.com/v1alpha1\nkind: DNSRecordSet\n..."
}
-----------------------
Apply changes? [y/N]:
```

**VO:**
> This is the whole point of the video. You see the tool it wants to call and
> the exact arguments, in this case the full YAML it's about to apply. Default
> is No. Anything other than a `y` cancels, and the assistant is told you
> declined so it can ask what to do instead.

Type `n`. Show the assistant acknowledging the decline.

**VO:**
> Say no and nothing happened. Let's ask again and say yes.

```
> ok, go ahead and add it
```

Type `y`. Then:

```
> now delete that record
```

Preview shows `delete_resource`. Type `y`.

**VO:**
> Same gate on delete. Same preview, same default of No.

Type `exit`.

---

## Beat 4: Pipe mode is read-only by design (4:30–5:10)

**On screen:**

```
echo "how many DNS zones do I have?" | datumctl ai
```

**VO:**
> Pipe a question in and it answers like any other CLI tool. Useful in scripts
> and in other agents.

```
echo "delete the example-com zone" | datumctl ai
```

Expected on stderr:

```
[ai] mutation skipped: delete_resource requires interactive mode (not a terminal)
```

**VO:**
> But try a mutation with no terminal attached and it's declined
> automatically. Not prompted, declined. If there's no human to say yes,
> there's no yes. That makes it safe to wire into automation without worrying
> that a clever prompt turns into a deletion.

---

## Closing beat (5:10–5:45)

**On screen, final card:**

```
datumctl ai config set anthropic_api_key ...
datumctl ai "any question"
datumctl ai                      # interactive session
echo "question" | datumctl ai    # read-only pipe mode
```

**VO:**
> Reads run. Writes ask. Pipes can't write at all. Everything the assistant
> does goes through the same API and the same permissions as your own
> datumctl session, so it can't do anything you couldn't.
>
> Ask it the questions you'd otherwise answer with four commands and a
> JSONPath cheat sheet. Let it draft the manifest. Then read the preview
> before you type `y`.

---

## Cheat sheet for the description / pinned comment

| Task | Command |
|---|---|
| Save an API key | `datumctl ai config set anthropic_api_key sk-ant-...` |
| Save a default project | `datumctl ai config set project my-project` |
| Show config (keys redacted) | `datumctl ai config show` |
| One-shot question | `datumctl ai "list my DNS zones"` |
| Interactive session | `datumctl ai` |
| Pipe mode (read-only) | `echo "..." \| datumctl ai` |
| Override model | `datumctl ai "..." --model gpt-4o` |
| Override scope | `datumctl ai "..." --project other` |
| Cap the agent loop | `datumctl ai "..." --max-iterations 5` |

Tools that run immediately: `list_resource_types`, `get_resource_schema`,
`list_resources`, `get_resource`, `validate_manifest`, `change_context`.
Tools that always prompt: `apply_manifest`, `delete_resource`.

## Presenter notes

- Set the API key **before** recording with `ai config set`, then on camera run
  `config show` instead of `config set` so no real key ever appears.
- Model answers vary run to run. Record the read-only beat twice and keep the
  cleaner take. The preview block in beat 3 is deterministic; the prose
  around it is not.
- Have at least two DNS zones, one of them not yet Ready, so the "which have
  a problem" question has something to find. A zone whose nameservers have
  not been delegated works well.
- If the assistant validates before applying you'll see a `validate_manifest`
  call first. That's a read and does not prompt. Point it out if it happens.
- The record-set manifest shape in beat 3 is whatever the model drafts from
  the live schema. Check it in the preview on camera. That's the message.
- Keep `--max-iterations` at the default. Lowering it to speed the demo can
  cut off the agent before it reaches the confirmation prompt.
- The assistant's name in the banner is Patch. Don't make a thing of it.
