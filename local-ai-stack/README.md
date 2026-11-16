# Local AI Stack

A private, self-hosted ChatGPT-style assistant for one Ubuntu server. It
answers from your own documents and has two expert assistants built in:

- **coder**: writes complete, tested, production-style code (your "perfect code" prompt).
- **debugger**: finds the root cause of a bug and proves the fix (your "perfect debugging" prompt).

Everything runs on your server. Nothing is sent to an AI company.

| Part                                                   | What it does                                          | Included                                                         |
| ------------------------------------------------------ | ----------------------------------------------------- | ---------------------------------------------------------------- |
| [Ollama](https://github.com/ollama/ollama)             | Runs the AI models                                    | Always                                                           |
| [Qdrant](https://github.com/qdrant/qdrant)             | Long-term memory for your documents                   | Always                                                           |
| [Open WebUI](https://github.com/open-webui/open-webui) | The chat website, with document upload                | On by default (`chat`)                                           |
| [n8n](https://github.com/n8n-io/n8n)                   | Automations: webhooks, schedules, APIs                | Optional (`automation`)                                          |
| [ComfyUI](https://github.com/Comfy-Org/ComfyUI)        | Image generation                                      | Optional (`image`), needs 8 GB RAM                               |
| [OpenClaw](https://github.com/openclaw/openclaw)       | Personal agent for files, terminal and messaging apps | Optional (`openclaw`), needs 8 GB RAM                            |
| [Cline](https://github.com/cline/cline)                | AI coding inside VS Code on your computer             | Connects to this server's Ollama; see [Cline](#cline-in-vs-code) |

## What fits on your server

Your server: Ubuntu 24.04, 4 vCPU, 2 GB RAM, 100 GB disk, no graphics card.

| Part                    | On 2 GB RAM    | Why                                                                                                                 |
| ----------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------- |
| Ollama + Qdrant         | Yes            | Ollama uses about 110 MB idle, Qdrant about 30 MB (measured)                                                        |
| Chat model (1.5B)       | Yes, slowly    | About 1.2 GB while answering. Expect a few words per second on 4 vCPU                                               |
| Open WebUI              | Yes, tight     | Several hundred MB (estimate). The installer adds 4 GB of swap so nothing crashes                                   |
| n8n                     | Yes            | About 460 MB (measured). Running it together with chat leans on swap                                                |
| ComfyUI                 | **No**         | Image models need several GB of RAM. Blocked unless you pass `--force`                                              |
| OpenClaw (local models) | **No**         | It needs a tool-calling model with 16K+ context; its docs set an 8 GiB floor. Blocked unless you pass `--force`     |
| Cline (local models)    | **Not really** | Connects fine, but its instructions are too large for models that fit in 2 GB. Use it with a bigger server or model |

**Be realistic about quality:** a model small enough for 2 GB is far weaker
than ChatGPT. The coder and debugger assistants follow your prompts' structure,
but expect simple, sometimes wrong code. Upgrading to 8 GB of RAM lets you use a
7B model (set `CHAT_MODEL=qwen2.5-coder:7b`) and unlocks ComfyUI and OpenClaw.

## Install (about 10 minutes)

1. **Log in to your server:** `ssh root@YOUR_SERVER_IP`
2. **Get this folder onto the server.** For example, clone the repository that
   contains it, then go into the folder:

   ```sh
   git clone https://github.com/YOUR_ACCOUNT/YOUR_REPO.git
   cd YOUR_REPO/local-ai-stack
   ```

3. **Install:**

   ```sh
   sudo ./stack install
   ```

   It shows what it will do and asks before changing anything:
   - installs Docker from Docker's official repository (if missing)
   - adds 4 GB of swap (extra memory on disk) so the server doesn't run out
   - creates `.env` with random passwords
   - downloads Ollama, Qdrant and Open WebUI, and the models (about 7 GB in total)
   - builds the **coder** and **debugger** assistants from your prompts

4. **Open the chat from your own computer.** On the server, run
   `./stack tunnel`. It prints one `ssh` command. Run that command **on your
   computer** and leave it open, then visit <http://localhost:3000>.
5. **Create your account.** The first account you create becomes the
   administrator. Do this right away.

Check everything at any time with `./stack doctor`.

## Using it

- **Chat:** pick **coder** or **debugger** at the top of the chat page.
  **coder** is the default.
- **Your documents:** click **+** in the message box to attach a PDF or text
  file and ask about it. For a permanent library, go to **Workspace >
  Knowledge**, create a collection, upload files, then type `#` in a chat to
  use it. Documents are stored in Qdrant.
- **From the terminal:**

  ```sh
  ./stack ask coder "Write a Python function that removes duplicate lines from a file"
  ./stack ask debugger < error-log.txt
  ```

- **Web search** is off so everything stays offline. To turn it on, go to
  **Admin Panel > Settings > Web Search** (DuckDuckGo needs no key).
- **Voice input** works in the chat page, but it loads a speech model that
  needs extra memory; on 2 GB it may be slow.

## Optional parts

### n8n (automations)

```sh
./stack enable automation
```

Open <http://localhost:5678> through the tunnel and create the owner account.
Inside n8n, connect to the other parts with these addresses:

- **Ollama** credential: Base URL `http://ollama:11434`
- **Qdrant** credential: URL `http://qdrant:6333`, API key = `QDRANT_API_KEY` from `.env`

Turn it off again with `./stack disable automation`; your workflows are kept.

### ComfyUI (images) and OpenClaw (personal agent)

```sh
./stack enable image      # ComfyUI, CPU only
./stack enable openclaw   # installs OpenClaw with npm (needs Node.js 24.16+)
```

Both refuse to run on less than 8 GB of RAM and explain why. Add `--force` to
try anyway. OpenClaw's own onboarding (`openclaw onboard --install-daemon`) is
left for you to run, because it asks you to accept the risks of an agent that
runs commands on your server. Point it at Ollama with base URL
`http://127.0.0.1:11434`.

### Cline in VS Code

Cline runs on your computer, not the server. With the `./stack tunnel` command
running, set Cline's **API Provider** to **Ollama**, **Base URL** to
`http://localhost:11434` and the model to `coder`. Cline's instructions are
long, so small models often fail at its tool use; it works much better with a
7B+ model on a larger server.

## Settings

All settings live in `.env`; the comments there explain each one. After editing,
run `./stack up` (or `./stack models` after changing a model). Common changes:

| Setting                 | Default              | Change it to…                                                                         |
| ----------------------- | -------------------- | ------------------------------------------------------------------------------------- |
| `CHAT_MODEL`            | `qwen2.5-coder:1.5b` | `qwen2.5-coder:0.5b` for speed, or a 7B model on 8 GB+ RAM. Then run `./stack models` |
| `OLLAMA_CONTEXT_LENGTH` | `4096`               | Higher lets it read more at once, but uses more memory                                |
| `BIND_ADDRESS`          | `127.0.0.1`          | `0.0.0.0` makes the web pages public. See [Security](#security)                       |
| `COMPOSE_PROFILES`      | `chat`               | Use `./stack enable` and `./stack disable` instead of editing this                    |

Open WebUI reads its settings from `.env` only the first time it starts. After
that, change them in its **Admin Panel**.

## Commands

| Command                             | What it does                                        |
| ----------------------------------- | --------------------------------------------------- |
| `sudo ./stack install`              | Install everything (safe to run again)              |
| `./stack tunnel`                    | Show how to open the web pages from your computer   |
| `./stack doctor`                    | Check that everything works                         |
| `./stack status`                    | Containers, memory use and loaded models            |
| `./stack ask coder\|debugger "…"`   | Ask an assistant in the terminal                    |
| `./stack models`                    | Download models and rebuild the assistants          |
| `./stack enable` / `disable <part>` | Turn parts on or off (data is kept)                 |
| `./stack logs [service]`            | Follow a service's log                              |
| `./stack backup`                    | Save chats, documents and workflows to `backups/`   |
| `./stack update`                    | Get newer versions and rebuild the assistants       |
| `./stack up` / `down`               | Start or stop everything                            |
| `./stack uninstall [--purge]`       | Remove containers; `--purge` also deletes your data |

## Editing the assistants

The assistants' instructions are plain text files:
[`assistants/coder.md`](assistants/coder.md) and
[`assistants/debugger.md`](assistants/debugger.md). Edit them, then run
`./stack models`. To add another assistant, add a file there and a line to
`ASSISTANTS` at the top of `stack`. A prompt cannot contain three double quotes
in a row (`"""`).

The debugging prompt is your original with one fix: it numbered two rules
"5", so the rules are now numbered 1–11.

## Security

- The web pages, Ollama and Qdrant listen only on the server itself. You reach
  them through the SSH tunnel, so nobody else can.
- Ollama has no password, so it is never exposed to the network. Qdrant
  requires the API key from `.env`.
- `.env` holds your passwords and is readable only by its owner. Back it up:
  losing `N8N_ENCRYPTION_KEY` makes saved n8n credentials unreadable.
- If you set `BIND_ADDRESS=0.0.0.0`, the pages become public, and **Docker
  ignores the `ufw` firewall for them**. Only do this behind HTTPS (for example
  a reverse proxy such as Caddy) with strong passwords.

## Troubleshooting

| Problem                                 | Fix                                                                                         |
| --------------------------------------- | ------------------------------------------------------------------------------------------- |
| Replies are very slow                   | Expected on CPU. Try `CHAT_MODEL=qwen2.5-coder:0.5b`, then `./stack models`                 |
| "model requires more system memory"     | Run `sudo ./stack install` again to add swap, or stop n8n with `./stack disable automation` |
| The page at localhost:3000 doesn't load | Make sure the `ssh -N -L …` command from `./stack tunnel` is still running                  |
| Open WebUI is still "starting"          | Its first start takes a few minutes on a small server. Check with `./stack logs open-webui` |
| A model download fails                  | Check the name at <https://ollama.com/library> and the server's internet connection         |

## Tests

```sh
bash tests/unit.sh          # helpers: no Docker or root needed
bash tests/integration.sh   # runs the real stack in Docker on separate ports, then removes it
```

The integration test downloads the real models by default. To run it offline,
set `STACK_TEST_CHAT_GGUF` and `STACK_TEST_EMBED_GGUF` to local GGUF model files.
