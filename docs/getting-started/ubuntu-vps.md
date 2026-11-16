# Run REA on an Ubuntu VPS

This guide sets up REA on a rented Ubuntu server (a "VPS") step by step, in
plain language. When you finish, an AI agent on the server can use REA to study
websites and apps and explain how their features work.

You type every command below into the server's terminal over SSH. Lines that
start with `#` are notes and do nothing.

## What you need

- An Ubuntu 22.04 or 24.04 server. 2 GB of memory is enough for websites and
  JavaScript apps. Use 4 GB or more if you plan to decompile native programs
  with Ghidra.
- An SSH login to that server, either as `root` or as a user who can run `sudo`.
- An account for an AI agent that can run in a terminal, such as Claude Code.

## Step 1: Install the basics

```sh
sudo apt update
sudo apt install -y curl ca-certificates procps
```

`procps` provides the `ps` command. REA uses it to keep track of the programs
it starts, so it must be present.

## Step 2: Install Node.js 24

REA runs on Node.js. The version that Ubuntu ships is too old, so install
Node.js 24 from NodeSource, the usual source for Ubuntu servers:

```sh
curl -fsSL https://deb.nodesource.com/setup_24.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install -y nodejs
node --version
```

The last command should print `v24.22.1` or a newer 24.x version. REA needs
Node.js 22.x (22.23.4 or newer), 24.x (24.22.1 or newer) or 26.12.1 or newer.

## Step 3: Install REA

```sh
sudo npm install --global rea-agents
rea --version
```

This puts the `rea` command where every login can find it.

<details>
<summary>Using the install script instead</summary>

The [official install script](https://github.com/morluto/rea/blob/main/install.sh)
installs REA into `~/.local/bin` for your user only. Ubuntu does not always
search that folder. The `root` user's default settings never do. If `rea`
then reports "command not found", the script prints the exact line to fix it.
That line is:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Add the same line to the end of `~/.bashrc` to keep it for future logins.

</details>

## Step 4: Install your AI agent

Install the agent you want to use on the server. For example, Claude Code:

```sh
sudo npm install --global @anthropic-ai/claude-code
```

Start it once with `claude` and sign in, then quit it.
[Other agents work too](installation.md#supported-agents).

## Step 5: Connect REA to your agent

If you log in as `root` and want REA to study websites, first read
[Step 7](#step-7-optional-let-rea-study-websites). It explains two settings to
include in this command.

```sh
rea setup
```

Setup asks which agents to connect, shows every file it will change, and waits
for your approval. It backs up each file before changing it. Afterward, restart
your agent so it loads REA.

## Step 6: Check that everything works

```sh
rea doctor
```

The report lists every tool REA can use. Lines that say
`missing_analysis_engine` are **optional** add-ons for deeper native-program
analysis, such as Ghidra or Hopper. Websites and JavaScript apps work without
them. Look for:

- `node` and `host`: these must be `ok: true`.
- `registration:<your agent>`: this should be `ok: true` after setup. If it is
  not, run `rea setup` again and restart the agent.

## Step 7 (optional): Let REA study websites

A server has no screen, so the browser runs "headless" (invisible). Install
Google Chrome:

```sh
curl -fsSLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
```

Google publishes this package for x86-64 (Intel/AMD) servers only. On an ARM
server, use another Chromium-family browser and pass its path where this guide
uses `/usr/bin/google-chrome`.

REA can use the browser in two ways.

**REA starts its own browser for each task.** This is best on a server, because
your agent can script clicks and typing. Tell setup where Chrome is. If you
log in as `root`, also allow Chrome to run without its sandbox: Chrome refuses
to start as `root` otherwise.

```sh
# As root:
REA_BROWSER_EXECUTABLE=/usr/bin/google-chrome REA_BROWSER_NO_SANDBOX=true rea setup
# As a normal user:
REA_BROWSER_EXECUTABLE=/usr/bin/google-chrome rea setup
```

Setup saves these settings in your agent's REA registration, so they apply
every time the agent starts REA. Restart the agent afterward.

**REA connects to a browser you started.** Start Chrome with a debugging port,
then name the port in your request:

```sh
google-chrome --headless=new --no-sandbox --remote-debugging-port=9222 \
  --user-data-dir="$HOME/rea-browser-profile" https://example.com &
```

Leave out `--no-sandbox` when you are not `root`. Chrome listens only on the
server itself (`127.0.0.1`). **Never open port 9222 in your firewall**:
anyone who reaches it can control that browser. Stop the browser when you are
done with `pkill -f rea-browser-profile`.

See the [website observation guide](../guides/web/browser-observation.md) for
everything REA records.

## Step 8: Ask your agent

Start your agent in any folder and ask in plain words. For example:

```text
Use REA to study https://example.com. Explain how its search box works:
which scripts run, which network requests it makes, and what comes back.
Show me the evidence.
```

```text
Use REA to analyze the Electron app in /root/apps/example and explain how it
saves user settings.
```

## Using REA on the server from your own computer

Your agent can also run on your laptop and start REA on the server over SSH.
For an agent that accepts a custom MCP server command, register:

```json
{
  "mcpServers": {
    "rea": {
      "command": "ssh",
      "args": ["-T", "root@your-server", "/usr/bin/rea", "mcp"]
    }
  }
}
```

This requires an SSH key login that works without a password prompt. Files you
ask REA to analyze must then be on the server, not your laptop. This setup was
not tested for this guide.

## Keep REA up to date

```sh
sudo npm install --global rea-agents@latest
rea setup
```

Restart your agent afterward.

## Common problems

| What you see                                     | What to do                                                                                                        |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `rea: command not found`                         | Run `export PATH="$HOME/.local/bin:$PATH"`, or reinstall with `sudo npm install --global rea-agents`.             |
| `Node.js ... is unsupported`                     | Repeat [Step 2](#step-2-install-nodejs-24).                                                                       |
| "The selected browser could not start" as `root` | Repeat the setup command in [Step 7](#step-7-optional-let-rea-study-websites) with `REA_BROWSER_NO_SANDBOX=true`. |
| `endpoint_unreachable` when using port 9222      | Chrome is not running or used another port. Start it again as shown in Step 7.                                    |
| Your agent does not list REA tools               | Run `rea doctor`, then `rea setup`, then restart the agent.                                                       |

For everything else, see [installation and setup](installation.md) and
[readiness and troubleshooting](installation.md#check-readiness-for-your-task).
