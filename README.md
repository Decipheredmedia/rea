<div align="center">

**English** · [简体中文](docs/readme/README_zh.md) · [繁體中文](docs/readme/README_zh-TW.md) · [日本語](docs/readme/README_ja.md) · [한국어](docs/readme/README_ko.md) · [Türkçe](docs/readme/README_tr.md) · [Русский](docs/readme/README_ru.md) · [Tiếng Việt](docs/readme/README_vi.md) · [ไทย](docs/readme/README_th.md) · [Deutsch](docs/readme/README_de.md) · [Español](docs/readme/README_es.md) · [Français](docs/readme/README_fr.md) · [Українська](docs/readme/README_uk.md) · [Polski](docs/readme/README_pl.md) · [Português (Brasil)](docs/readme/README_pt-BR.md) · [العربية](docs/readme/README_ar.md) · [فارسی](docs/readme/README_fa.md) · [Bahasa Indonesia](docs/readme/README_id.md) · [Italiano](docs/readme/README_it.md)
· [Ελληνικά](docs/readme/README_el.md) · [മലയാളം](docs/readme/README_ml.md) · [Roman Urdu](docs/readme/README_ur-Latn.md) · [Română](docs/readme/README_ro.md) · [Български](docs/readme/README_bg.md)

# REA: Reverse Engineer Anything

### One MCP for reverse engineering across binaries, applications, and runtime behavior.

**See a feature you like. Understand how it works, down to the binary level.**

[![npm version](https://img.shields.io/npm/v/rea-agents?style=flat-square&color=cb3837)](https://www.npmjs.com/package/rea-agents)
[![MCP tool catalog](https://img.shields.io/badge/MCP-tool_catalog-5c4ee5?style=flat-square)](docs/reference/mcp-contracts.md#generated-catalog)
[![Node.js requirements](https://img.shields.io/badge/Node.js-requirements-339933?style=flat-square&logo=nodedotjs&logoColor=white)](#what-you-can-analyze)
[![skills.sh](https://skills.sh/b/morluto/rea?style=flat-square)](https://skills.sh/morluto/rea/reverse-engineer-anything)
[![MIT license](https://img.shields.io/badge/license-MIT-f4c430?style=flat-square)](LICENSE)
[![Discord](https://img.shields.io/discord/1556595354999332884?logo=discord&logoColor=white&label=Discord&color=5865F2)](https://discord.gg/GkcryMnJDM)

<a href="https://trendshift.io/repositories/82054?utm_source=repository-badge&amp;utm_medium=badge&amp;utm_campaign=badge-repository-82054" target="_blank" rel="noopener noreferrer"><img src="https://trendshift.io/api/badge/repositories/82054" alt="morluto%2Frea | Trendshift" width="250" height="55"/></a>

**[Website](https://rea.tools/) · [Guides](https://rea.tools/guides/) · [Showcases](https://rea.tools/showcase/)**

<a href="https://discord.com/invite/GkcryMnJDM"><img alt="Join the REA community on Discord" src="https://img.shields.io/badge/Join%20us%20on%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" height="40"></a>

[Quick start](#quick-start) · [How REA works](#how-rea-works) · [What you can analyze](#what-you-can-analyze) · [Showcases](#showcases) · [Build RL environments](#build-rl-environments) · [FAQ](#faq) · [Documentation](#documentation)

<code>npx rea-agents setup</code>

</div>

> [!IMPORTANT]
> Get REA from [morluto/rea](https://github.com/morluto/rea),
> [rea.tools](https://rea.tools/), or the [rea-agents npm package](https://www.npmjs.com/package/rea-agents).
> Follow the installation and release links from these official sources. A similar
> repository name or copied README does not establish that a download is official.

<div align="center">

<br />

<img src="docs/assets/rea-hopper-analysis.png" alt="REA launching its analysis bridge inside Hopper while inspecting a native binary" width="1200" />

<br /><br />

<table aria-label="REA community">
<tr>
<td align="center" width="360">
  <a href="https://discord.gg/GkcryMnJDM">
    <img src="docs/assets/discord.svg" height="42" alt="Discord" /><br />
    <strong>Join the Reverse Engineering Community</strong>
  </a><br />
  <sub>Discord · Q&amp;A · Show and Tell</sub>
</td>
</tr>
</table>

<br />

</div>

---

## What is REA?

Ever used an app or website and wondered "how did they build that?" REA helps
you find out.

REA gives your AI agent (such as Claude Code, Cursor or Codex) a toolbox for
looking inside finished software: websites, desktop apps, phone apps and
programs. You ask a question in plain words, for example "how does the search
box on this site work?" Your agent uses REA to look, explains what it found,
shows the evidence behind each conclusion, and can build a similar feature for
your own project.

A few things to know:

- **It runs on your machine.** REA analyzes everything locally and uploads
  nothing. Your agent sees the results, and the agent's AI provider has its own
  data policy.
- **It shows its work.** Every answer comes with evidence, plus anything REA
  could not determine.
- **You can start without extra tools.** Websites and JavaScript or Electron
  apps work out of the box. Deeper analysis of compiled programs uses an
  optional analysis engine: Hopper, Ghidra, IDA or Kuna. Setup can install
  Hopper for you if you approve.

> **[Visit the REA website](https://rea.tools/)** for illustrated guides and
> real case studies.

## How REA works

1. You ask your agent a question about an app or website.
2. Your agent calls REA's tools to inspect it.
3. REA returns what it found and the evidence for it.
4. Your agent explains the answer, digs further, or writes and tests code for you.

The same tools are also available as terminal commands.

![REA investigation flow: your agent asks about a local target, REA inspects and traces it using analysis tools, and the agent uses the returned code, references and unknowns to explain, implement and test.](website/public/assets/figures/rea-investigation-flow.svg)

[Open the full-size figure](website/public/assets/figures/rea-investigation-flow.svg).

## Install and set up

### What you need

- **Node.js and npm.** REA needs Node.js 22.x (22.23.4 or newer), 24.x (24.22.1
  or newer), or 26.12.1 or newer; 24 is recommended. Check with
  `node --version`. If you don't have it, download it from nodejs.org.
- **An AI agent** that can use MCP tools, such as Claude Code, Codex, Cursor or
  Gemini CLI. See the [supported agents](docs/getting-started/installation.md#supported-agents).
- **Chrome or another Chromium-family browser** if you want to study websites.

### Option A: Your own computer (Mac, Windows or Linux)

<a id="quick-start"></a>

Run one command:

```bash
npx rea-agents setup
```

What happens:

1. Setup asks which of your agents should use REA.
2. It shows every change it plans to make and waits for your **yes**.
3. It adds REA to each agent's settings, backs up each settings file first, and
   installs REA's instructions for the agent.
4. **Restart your agent.** REA's tools are then available.

Run the command from a folder you trust, outside the project you want to study.
Setup remembers where REA was downloaded, so keep that npm download cache.
Details are in the [installation and setup guide](docs/getting-started/installation.md).

### Option B: An Ubuntu server (VPS)

REA works on Ubuntu 22.04 and 24.04 servers. The short version, as `root` or
with `sudo`:

```sh
# 1. Basics, then Node.js 24 (Ubuntu's own Node.js is too old)
sudo apt update && sudo apt install -y curl ca-certificates procps
curl -fsSL https://deb.nodesource.com/setup_24.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh && sudo apt install -y nodejs

# 2. REA itself
sudo npm install --global rea-agents

# 3. Connect REA to your agent (install your agent on the server first)
rea setup
```

For websites, install Google Chrome. If you log in as `root`, run setup this
way so REA can start Chrome:

```sh
REA_BROWSER_EXECUTABLE=/usr/bin/google-chrome REA_BROWSER_NO_SANDBOX=true rea setup
```

The [Ubuntu VPS guide](docs/getting-started/ubuntu-vps.md) explains every step,
including installing Chrome, using REA from your laptop over SSH, and fixing
common problems.

### Optional: analysis engines for compiled programs

To read the code inside compiled programs (for example `.exe` files, Mac apps
or Linux binaries), REA uses an analysis engine you install:

| Engine | Cost             | How REA finds it                                              |
| ------ | ---------------- | ------------------------------------------------------------- |
| Hopper | Paid, with demo  | `rea setup` can install it after you approve                  |
| Ghidra | Free             | Set `GHIDRA_INSTALL_DIR` to the extracted Ghidra 12.1+ folder |
| IDA    | Paid             | Set `REA_IDA_MCP_CONFIG` (the IDA guide is linked below)      |
| Kuna   | See vendor terms | Set `REA_KUNA_COMMAND` (the Kuna guide is linked below)       |

Websites and JavaScript/Electron apps do not need any of these.

### Settings in plain terms

REA is configured with environment variables: named settings you type before
a command, such as `GHIDRA_INSTALL_DIR=/opt/ghidra rea setup`. When you set
one before running `rea setup`, setup saves it into your agent's REA
registration, so it applies every time the agent starts REA. Common ones:

| Setting                  | What it does                                               |
| ------------------------ | ---------------------------------------------------------- |
| `REA_BROWSER_EXECUTABLE` | Which browser REA starts for website tasks                 |
| `REA_BROWSER_NO_SANDBOX` | `true` lets Chrome run as `root` (needed on many servers)  |
| `GHIDRA_INSTALL_DIR`     | Where Ghidra is installed                                  |
| `HOPPER_LAUNCHER_PATH`   | Where Hopper's launcher is, if it isn't in the usual place |
| `REA_JADX_MCP_JAR`       | The JADX bridge file used for Android apps                 |

`REA_MCP_OUTPUT_SCHEMA_PROFILE=compact` also sends your agent short
descriptions of each tool's results. Leaving it unset is the default and uses
fewer tokens. REA checks every result either way.

On Linux, REA also needs the standard `ps` command (package `procps`) to keep
track of the programs it starts. Most systems already have it.

### Check that it works

```sh
rea doctor
```

This lists what REA can use. Entries marked `missing_analysis_engine` are
optional engines you haven't installed. Websites and JavaScript apps still
work. If your agent's registration shows a problem, run setup again and restart
the agent. The [Documentation](#documentation) section links the full
troubleshooting guide, and the [FAQ](#faq) explains how to add REA to an agent
by hand.

## Use REA

### Ask your agent

Describe what you want in plain words:

```text
Understand how search works in the Notes app, show me the evidence, and build a
similar feature for my project.
```

Replace Notes with your target app and the feature you want to understand.

To study a website, open it in a Chrome window started with
`--remote-debugging-port=9222` and a separate profile, then tell your agent to
use the browser on port 9222. On a server, REA can also start its own invisible
browser. The website row in [What you can analyze](#what-you-can-analyze)
links the full guide.

### Use the terminal

Analyze an unpacked JavaScript or Electron app folder, or an `.asar` file:

```bash
npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json
```

The result lists the app's modules, imports and Electron connections, with
evidence. Replace the path with your own, such as `"D:/apps/example"` on
Windows.

To install the `rea` command permanently:

```bash
npm install --global rea-agents
rea --help
```

For compiled programs, set up an analysis engine first. The
[CLI and Evidence guide](docs/getting-started/cli.md) covers every command.

## Update REA

REA changes quickly and new versions fix bugs often, so update regularly.

If you installed with `npm install --global` or `bun add --global`:

```bash
rea update
```

`rea --update` does the same. Bun users need Bun 1.2.17 or later. Then run the
setup command that the update prints, to refresh your agents.

If you use `npx`:

```bash
npx rea-agents@latest setup
```

Review the changes and restart your agent. For one-off commands, use
`npx rea-agents@latest` followed by the command, or `bunx rea-agents@latest`
with Bun.

On a server installed with `sudo npm install --global`, run
`sudo npm install --global rea-agents@latest`, then `rea setup`.

<a id="current-status"></a>

## What you can analyze

This table lists everything REA can look inside. The last column says what
extra software, if any, each kind of target needs, and links to its guide.

| Target                  | What REA returns                                                                                  | Requirements and guide                                                                                                                                               |
| ----------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Desktop installations   | Runtime candidates, supporting files, component markers and next probes                           | Built-in bounded directory/header inspection; [desktop applications](docs/desktop-applications.md)                                                                   |
| Native binaries         | Pseudocode, assembly, strings, symbols, calls and references                                      | Hopper, Ghidra, IDA or Kuna; [native analysis](docs/guides/native/native-investigation.md)                                                                           |
| Offline ELF layout      | Sections, segments, original symbols/relocations and static mitigation candidates                 | Caller-supplied pwntools on Linux x64; [binary diagnostics](docs/guides/native/binary-diagnostics.md)                                                                |
| Go binaries             | Embedded compiler version, modules, replacements and build settings                               | Built-in static ELF/PE/thin Mach-O inspection; no Go installation required                                                                                           |
| GPU code objects        | CUDA/HIP targets, selected kernel parameters and resources, retained PTX text                     | Built-in static ELF/PE/fatbin/CUBIN/PTX inspection; [GPU code objects](docs/gpu-code-objects.md)                                                                     |
| Model artifacts         | GGUF / safetensors metadata, tensor declarations and derived totals                               | Built-in header inspection; optional full-file hash; [model files](docs/model-artifacts.md)                                                                          |
| IL2CPP metadata         | Unity global-metadata.dat assembly images, type and method names and index ranges                 | Built-in static decoding of versions 24, 27, 29, 31 and 39; no Unity required                                                                                        |
| Godot PCK               | Archive inventory and extraction, original header/directory facts and selected content identities | Built-in static formats 2, 3 and 4; no Godot required                                                                                                                |
| Rust binaries           | Embedded cargo-auditable crate names, versions, sources and dependency edges                      | Built-in static ELF/PE/thin Mach-O inspection; [Rust binaries](docs/rust-binaries.md)                                                                                |
| PE certificates         | Authenticode WIN_CERTIFICATE entries and PKCS#7 signer/X.509 identity fields                      | Built-in static PE inspection; [PE certificates](docs/pe-certificates.md)                                                                                            |
| PE imports              | Import and delay-load DLL names, ordinals, IAT RVAs and pefile import hash                        | Built-in static PE inspection; [PE imports](docs/pe-imports.md)                                                                                                      |
| Windows shortcuts       | Shell Link target, arguments, working dir, ExtraData and Tracker droid facts                      | Built-in static LNK inspection; [Windows shortcuts](docs/guides/native/windows-shortcut.md)                                                                          |
| ELF notes               | PT_NOTE/SHT_NOTE owners, types, GNU build-id and ABI-tag fields                                   | Built-in static ELF inspection; [ELF notes](docs/elf-notes.md)                                                                                                       |
| Binary hardening        | PIE, NX, RELRO, CFG and related header flags for ELF, PE and Mach-O                               | Built-in static header inspection; [binary hardening](docs/binary-hardening.md)                                                                                      |
| Apple IPS crashes       | .ips metadata, threads, images, registers and documented crash classes                            | Built-in static JSON inspection; [Apple IPS](docs/apple-ips.md)                                                                                                      |
| Linux kernel modules    | .modinfo keys, __versions CRCs, this_module presence, and signature trailer                       | Built-in static ELF inspection; [kernel modules](docs/kernel-modules.md)                                                                                             |
| Erlang BEAM             | IFF chunks, atoms, exports, imports, lambdas and the Code header                                  | Built-in static BEAM inspection; [Erlang BEAM](docs/erlang-beam.md)                                                                                                  |
| WASM artifact           | Validation, sections, exact import/export WAT forms and decoded WAT                               | Caller-supplied WABT 1.0.42; `inspect_wasm_artifact`                                                                                                                 |
| EVM bytecode            | Dispatch selectors, byte offsets, inferred arguments and mutability                               | Local raw/hex carrier on Linux x64; [offline EVM guide](docs/guides/evm/evm-bytecode.md)                                                                             |
| SQLite databases        | Tables, columns, indexes, views, triggers and selected ordinary-table rows                        | Local database/WAL snapshot; Node.js 24.x >=24.15 or 26+ with native SQLite limits                                                                                   |
| Recorded Linux crashes  | Raw notes, every recorded thread's registers/signals and optional mapping candidates              | Caller-supplied pwntools on Linux x64; optional GDB/pwndbg; [recorded crashes](docs/guides/native/recorded-crashes.md)                                               |
| JavaScript / Electron   | Modules, imports, source maps, routes, IPC, native add-ons, `rea audit-release-exposure`          | Node.js and npm; Linux: procps-compatible `ps`; [application analysis](docs/guides/javascript/javascript-application-workflows.md)                                   |
| Websites                | Page structure, scripts, network observations and requested screenshots                           | A Chrome-family browser; [browser analysis](docs/guides/web/browser-observation.md)                                                                                  |
| Saved network captures  | Requests, responses, exposed payloads and source locations                                        | HAR or Fiddler Everywhere SAZ; mitmdump on Linux for native mitmproxy; [capture guide](docs/guides/web/web-network-captures.md)                                      |
| .NET assemblies         | Metadata, CIL instructions, declared native dependencies and build comparisons                    | None (static only); [managed-code guide](docs/guides/managed/managed-code-analysis.md)                                                                               |
| Android APKs            | Manifest declarations, classes, decompiled methods and references                                 | Headless JADX and a full JDK on Linux/macOS/Windows x64; [Android guide](docs/guides/android/android-analysis.md)                                                    |
| APK signatures          | v1/v2/v3/v3.1 signers, certificate fingerprints, key rotation and digest self-consistency         | None (static only); `inspect_apk_signature`                                                                                                                          |
| Android devices         | Devices, packages, processes, logs, dumps, screen captures, and APK/file transfers                | Caller-supplied adb (emulator or hardware); [ADB guide](docs/guides/android/adb-device-analysis.md)                                                                  |
| JEB projects            | Engine-backed project units, artifact digests and type/method pseudo-code                         | A caller-started JEB client serving MCP, selected with REA_JEB_MCP_URL; [JEB guide](docs/providers/jeb-analysis.md)                                                  |
| Android resources       | Decoded manifest, string tables, locales and version facts                                        | Caller-supplied Apktool launcher; [resource guide](docs/guides/android/apktool-resource-analysis.md)                                                                 |
| Flutter apps            | Dart snapshot hash, per-ABI library digests and engine build provenance                           | None (static APK parsing); [Flutter guide](docs/guides/android/flutter-analysis.md)                                                                                  |
| Firmware                | Regions, extraction results and native-analysis handoffs                                          | Binwalk / Unblob on Linux; [firmware guide](docs/guides/firmware/firmware-analysis.md)                                                                               |
| Recorded packets        | Selected fields, repeated values, filters and decode-as rules                                     | Linux: TShark 4.x + prlimit; [capture guide](docs/guides/data/packet-captures.md)                                                                                    |
| Packet summaries        | Endpoints, DNS, TLS SNI, protocol distribution and HTTP requests                                  | Caller-supplied tshark and capinfos (Linux-verified); [pcap guide](docs/guides/data/pcap-analysis.md)                                                                |
| Recorded logic signals  | Decoder annotations, sample ranges and diagnostics                                                | Linux: sigrok-cli 0.7.2 + prlimit; [signal recordings](docs/guides/signals/signal-recordings.md)                                                                     |
| Packages and resources  | File inventories, digests, plists, Apple bundle anatomy and extracted resources                   | [Artifact and JavaScript guide](docs/guides/javascript/javascript-artifact-reconstruction.md), [Apple applications](docs/guides/apple/apple-application-analysis.md) |
| Process behavior        | Terminal output, interactions, exit and filesystem observations, and run comparisons              | Linux/macOS with a native PTY; [process capture](docs/guides/runtime/process-capture.md)                                                                             |
| PyInstaller executables | CArchive members, Python version, entry scripts and extracted bytecode                            | None (static only); [Python packaged applications](docs/python-packaged-applications.md)                                                                             |
| Deno compile binaries   | Virtual files, entry point, recorded options, npm snapshot length                                 | None (static only); [Deno compile executables](docs/deno-standalone.md)                                                                                              |

**Looking vs. running.** For most targets REA only reads the files and never
runs the app. Tools that capture runtime behavior do run or interact with the
target, using your user permissions; each runtime guide describes what it does.

For compiled programs, REA can also use GNU objdump and Rizin if you have them.
See the [reverse-engineering tools guide](docs/reverse-engineering-tools.md).
REA never installs or updates these for you.

<a id="choosing-a-deep-analysis-provider"></a>

**Choosing an analysis engine.** Each engine supports different file types and
systems. See [Hopper and Ghidra setup](docs/getting-started/installation.md#hopper), the
[IDA guide](docs/providers/ida-provider.md) (including an optional native MCP bridge), the
[Kuna decompiler guide](docs/kuna-provider.md), and
[experimental Windows Ghidra support](docs/providers/windows-ghidra-p0.md).
Ghidra can also read [16-bit DOS programs](docs/providers/ghidra-dos.md).
If a large program times out while opening, give the engine more time with
`REA_GHIDRA_STARTUP_TIMEOUT_MS` or `REA_HOPPER_STARTUP_TIMEOUT_MS`.
To choose between engines, see the [CLI guide](docs/getting-started/cli.md#choose-a-provider).
Some features may be newer than the latest npm release; check
[release availability](docs/getting-started/installation.md#released-package-and-main).

## Showcases

<a href="https://rea.tools/showcase/">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/rea-showcases-dark.svg" />
    <img alt="Illustrations of the DX-Ball sound-pan, Notion clipboard-bridge, and TH04 bullet-ring showcases" src="docs/assets/rea-showcases.svg" />
  </picture>
</a>

### DX-Ball: reconstruct a sound-pan calculation

Follow a sound call into its position-to-pan helper, inspect the instructions,
and turn incomplete pseudocode into C. The reconstruction passes 3,205
original-x86 cases and reproduces all 63 compiled function bytes.

[Read the case study](https://rea.tools/showcase/dx-ball/) ·
[Reconstruction repository](https://github.com/N0zoM1z0/dx-ball)

### Notion: trace the Electron clipboard bridge

Find the renderer's clipboard API, follow it through preload and IPC into the
main process, and inspect the rich clipboard format.

[Read the case study](https://rea.tools/showcase/notion/)

### TH04: recover a DOS bullet-ring calculation

Inspect the original PC-98 game's 16-bit instructions, recover the fixed and
aimed angle calculations, and compare the reconstructed C++ with the
historical compiler output.

[Read the case study](https://rea.tools/showcase/th04/) ·
[Reconstruction repository](https://github.com/N0zoM1z0/th04)

### Build RL environments with REA

Record a web app session, turn its API into tools, and export an environment an AI agent can use. Run it with AgentEnv, then add tasks and reward checks for RL training or evaluation.

[Read the guide](https://rea.tools/guides/rl-environments/) ·
[Watch the video](https://x.com/reatools/status/2112574822584918075?s=20)

If you've used REA on something interesting, we'd love to see it. Share your
case in an [issue](https://github.com/morluto/rea/issues) or a
[pull request](https://github.com/morluto/rea/pulls), including the target,
your question, how REA helped, and what you found.

## Build RL environments

Give an AI agent a local environment to practice tasks such as finding an issue or creating a folder, without running the original app. Use it for reinforcement learning (RL) or to test how well an agent completes tasks.

REA turns recorded API requests and responses into tools the agent can call. The environment uses the recorded data and supports changes only when the recording confirms their effects.

With REA set up in your agent, replace the example URL and folder tasks below with your own:

```text
Use REA to build an RL environment from my test web app at
http://127.0.0.1:3000.
Cover listing, creating, renaming, and deleting folders. You may create and
remove test folders. Leave existing data unchanged.
Save it in a folder named my-env. Check which operations work and tell me
how to run it.
```

<details>
<summary>Use the command line instead</summary>

Use these commands if you already have a file containing the app’s recorded browser requests and responses. Running the result also requires AgentEnv and Docker.

```sh
rea environment-build ./session.har ./my-env --name my-env --json
agent-env run ./my-env
```

</details>

REA exports a runnable environment with a basic test to check that it starts and responds. Use it with your RL framework to define task goals, add reward checks, and run training.

[Build an environment](https://rea.tools/guides/rl-environments/) ·
[Environment reference](docs/agent-environments.md) ·
[Watch the demo on X](https://x.com/reatools/status/2112574822584918075?s=20)

### Desktop app environments

REA can also build an environment of a Linux desktop app, which an agent uses through screenshots, the mouse and the keyboard. From a one-line request, such as "Build me a Gnote environment where the agent adds olive oil to the shopping list note", your agent installs the app on a local build computer, writes the task, exports the environment and checks the task in a fresh computer. The machine that builds it needs Linux on amd64 or arm64, Docker and the agentenv framework version the guide pins.

[Set up desktop app environments](docs/desktop-build-computer.md)

## FAQ

<details>
<summary><strong>Which agents can use REA?</strong></summary>

Any agent that can use local MCP servers (MCP is the standard way agents plug
in tools). Setup handles the
[supported agents](docs/getting-started/installation.md#supported-agents) for you.
For any other agent, follow [manual MCP registration](docs/getting-started/installation.md#mcp-registry).

</details>

<details>
<summary><strong>Do I need an analysis engine?</strong></summary>

Only to read the code inside compiled programs. For that, REA uses Hopper,
Ghidra, IDA or Kuna, depending on the program. Websites, JavaScript/Electron
apps and .NET programs work without one. Setup can install Hopper if you
approve. Ghidra, IDA and Kuna use copies you install yourself. See
[engine setup](docs/getting-started/installation.md#hopper).

</details>

<details>
<summary><strong>Do I need to start Hopper first?</strong></summary>

No. REA starts Hopper when it needs it. On a Mac, the first launch may ask you
to choose demo mode or enter a license. Answer that prompt once, as the same
user, before your first REA task. Open Hopper by hand if needed. See
[Hopper startup and troubleshooting](docs/getting-started/installation.md#launcher-paths-and-troubleshooting).

</details>

<details>
<summary><strong>What does installing the skill from skills.sh do?</strong></summary>

The skill only gives your agent instructions for investigations. It doesn't
connect the tools. Run `npx rea-agents setup` to connect REA and install the
matching instructions, then restart your agent. See
[skill-only installation](docs/getting-started/installation.md#skill-only-installation).

</details>

<details>
<summary><strong>What code does REA return?</strong></summary>

For compiled programs: pseudocode (readable code rebuilt from the program) and
assembly. For JavaScript/Electron apps: the app's modules and how they connect.
Your agent uses these to write and test its own version. The
[showcases](#showcases) show complete examples.

</details>

<details>
<summary><strong>Does REA upload my app?</strong></summary>

No. REA analyzes everything on your machine. Your agent receives the results,
and the agent's AI provider has its own data policy.

</details>

<details>
<summary><strong>What should I do if I hit a bug?</strong></summary>

Update first: a newer version may already fix it.

If you installed with `npm install --global` or `bun add --global`:

```bash
rea update
```

If you set up your agent with `npx`:

```bash
npx rea-agents@latest setup
```

When you use an agent, finish the [setup refresh](#update-rea) and restart it.
Then retry the same task. If the problem is still there,
[open an issue](https://github.com/morluto/rea/issues) with your REA version,
what you were analyzing, the steps to reproduce it and the error message.

</details>

## Documentation

New to REA? Start with the website's [illustrated guides](https://rea.tools/guides/).
For every option and detail:

- [Installation and setup](docs/getting-started/installation.md): connecting agents, analysis engines, updating and removing REA.
- [Readiness and troubleshooting](docs/getting-started/installation.md#check-readiness-for-your-task): find out why an agent or engine isn't working.
- [CLI and Evidence](docs/getting-started/cli.md): terminal commands, choosing an engine, saving and comparing results.
- [MCP contracts](docs/reference/mcp-contracts.md) and [agent prompts](docs/getting-started/mcp-prompts.md): what each tool returns, and ready-made investigations.
- [Tool catalog](docs/reference/mcp-contracts.md#generated-catalog): the full, automatically generated list of tools and commands.
- [Roadmap](docs/development/roadmap.md): what's planned next.

Report security problems as described in [SECURITY.md](SECURITY.md).

## Star history

🎉 **400,000 GitHub stars — thank you!**

Thanks to everyone using REA, reporting bugs, requesting features, testing builds, and contributing fixes.

<a href="https://www.star-history.com/?repos=morluto%2Frea&amp;type=date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=morluto/rea&amp;type=date&amp;theme=dark&amp;legend=top-left" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=morluto/rea&amp;type=date" />
    <img alt="REA GitHub star history" src="https://api.star-history.com/chart?repos=morluto/rea&amp;type=date" />
  </picture>
</a>

## Disclaimer

See [DISCLAIMER.md](DISCLAIMER.md) for responsible-use guidance.

The project's position on illegal or unauthorized use covers all REA versions,
distribution channels, and platforms; each copy retains its applicable licenses.

REA is for lawful research, education, interoperability, software preservation,
and analysis of software you own or are authorized to examine.

## Contributing

We'd love your help with REA! [Open an issue](https://github.com/morluto/rea/issues) to
report a bug or suggest a feature, or [send a pull request](https://github.com/morluto/rea/pulls)
to improve the code or docs.

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and checks,
[testing](docs/development/testing.md) for verification lanes, and the
[architecture map](docs/architecture/architecture.mermaid) for selected layers and dependency paths.

## License

[MIT](LICENSE)

REA-authored code is licensed under MIT. Third-party material retains its own
licenses and copyright notices; see
[Third-party notices](THIRD_PARTY_NOTICES.md) for the dependency inventory,
preserved license texts, and external-tool terms.

**You must legally obtain and be authorized to use commercial tools**, including
IDA Pro / Hex-Rays decompilers, Hopper, and JEB, under their applicable
licenses. REA grants no tool license, key, or activation entitlement. Trials and
demos remain subject to vendor terms, including user, feature, automation, and
output sharing restrictions. Cracked copies, stolen keys, unauthorized key
sharing, and bypassing license restrictions are not authorized. This guidance
does not amend MIT or third-party licenses.
