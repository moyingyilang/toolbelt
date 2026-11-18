# Toolbelt

**All the toolkits, one belt.**

A terminal-only home for every toolkit I build: an interactive TUI to browse
them, a scriptable CLI to drive them, and a couple of bundled tools that run
right away. One bash script — no build step, no runtime dependencies beyond
bash and coreutils. Linux and Termux only: no GUI, no website, no Windows.

English | [中文](README.zh.md)

[![bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](toolbelt)
[![Linux + Termux](https://img.shields.io/badge/platform-Linux%20%2B%20Termux-4D6BFE?style=flat-square)](toolbelt)
[![License: MPL-2.0](https://img.shields.io/badge/license-MPL--2.0-blue?style=flat-square)](LICENSE)
[![TUI + CLI](https://img.shields.io/badge/mode-TUI%20%2B%20CLI-orange?style=flat-square)](toolbelt)

> **Status: 0.2 preview.** The TUI, the CLI, the responsive layouts and the
> bundled tools work; more toolkits and tools are still being added.

## What it is

- **A catalog** — 18 toolkits in 7 categories, declared in
  [`catalog/toolkits.ini`](catalog/toolkits.ini). Public repositories only;
  local device-specific research is generalized into [`tools/`](tools/) instead.
- **A TUI** — `toolbelt` with no arguments. Browse, search, open a repository or run a
  bundled tool without leaving the terminal.
- **A CLI** — `toolbelt list`, `search`, `show`, `run`, `open`, `categories`, `stats`,
  `doctor`, all with `--json`. Same program, two modes.
- **Bundled tools** — [`portscan`](tools/portscan/) and
  [`a64elf`](tools/a64elf/): portable versions of local scratch scripts.

## Preview

On a phone terminal (50 columns, stacked layout):

```text
┌ Toolbelt ───────────────────────────── 18 kits ┐
│ ★ 全部 · 18  (←→ 分类)                         │
├────────────────────────────────────────────────┤
│▸ ⚙ portscan                                    │
│  ⚙ a64elf                                      │
│  dsh-termux-toolkit                            │
│  dsh-plugins                                   │
│  android-termux-builders4JMNeXt                │
│  Fuck4DuerOS                                   │
│  EFML4A-docs                                   │
│  Zygisk-Il2CppDumper                           │
│  android_kernel_XiaoDu_RMX3511                 │
│  kernel_mi845_lineage                          │
├────────────────────────────────────────────────┤
│portscan                                        │
│● active · tool · Bash                          │
│license: MPL-2.0                                │
│category: 内置工具箱                            │
└────────────────────────────────────────────────┘
 ↑↓ ←→ ⏎ r / ? q                                  
```

On a desktop terminal (100 columns, three panes):

```text
┌ Toolbelt ──────────────────────────────────────────────────────────── 18 toolkits · 7 categories ┐
│ Categories         │ ★ 全部 (18)                    │ Details                                    │
│★ 全部            18│▸ ⚙ portscan                    │portscan                                    │
│⚙ 内置工具箱       2│  ⚙ a64elf                      │● active · tool · Bash                      │
│⌨ Termux 与 DSH    3│  dsh-termux-toolkit            │license: MPL-2.0                            │
│🔍 Android 逆向    3│  dsh-plugins                   │category: 内置工具箱                        │
│🔧 刷机与内核      2│  android-termux-builders4JMNeXt│tags: network,tcp,termux                    │
│📚 漫画阅读        4│  Fuck4DuerOS                   │                                            │
│🤖 游戏自动化      1│  EFML4A-docs                   │并行 TCP 端口扫描：纯 bash +                │
│🌐 站点与 Web      3│  Zygisk-Il2CppDumper           │/dev/tcp，主机、端口区间、并发度全部参数化  │
│                    │  android_kernel_XiaoDu_RMX3511 │                                            │
│                    │  kernel_mi845_lineage          │Parallel TCP port scan in pure bash over    │
```

## Quick start

```bash
git clone https://github.com/moyingyilang/toolbelt.git
cd toolbelt

./toolbelt          # TUI
./toolbelt list     # CLI
./toolbelt show portscan
```

On Termux only `git` is needed — bash and coreutils are already there.
To put it on your PATH:

```bash
install -m 0755 toolbelt "$PREFIX/bin/tb"     # Termux
install -m 0755 toolbelt ~/.local/bin/tb      # generic Linux
```

The script finds the catalog next to itself, so the `catalog/` and `tools/`
directories must stay beside `toolbelt`.

## Responsive by default

| terminal width | layout |
| --- | --- |
| `>= 92` columns | three panes: categories / toolkits / details |
| `< 92` columns | stacked: category bar, toolkit list, details below |

Phones, split terminals and narrow windows get the stacked layout
automatically. Force one with `TOOLBELT_LAYOUT=wide` or `TOOLBELT_LAYOUT=compact`.

```bash
TOOLBELT_LAYOUT=compact toolbelt   # force the phone layout on a big screen
```

## TUI keys

| key | action |
| --- | --- |
| `↑` `↓` / `k` `j` | move the selection |
| `←` `→` / `h` `l` / `Tab` | previous / next category |
| `PgUp` `PgDn` / `g` `G` | first / last toolkit |
| `/` | search (Enter applies, Esc cancels) |
| `Enter` | open the repository, or run the bundled tool |
| `o` / `r` | open repository URL / run bundled tool |
| `[` `]` | scroll the detail pane |
| `?` | key help |
| `q` / `Ctrl-C` | quit |

## CLI reference

| command | description | example |
| --- | --- | --- |
| `toolbelt` | open the TUI (lists the catalog off a TTY) | `toolbelt` |
| `toolbelt list` | list every toolkit, grouped by category | `toolbelt list -c termux` |
| `toolbelt search <q>` | search ids, names, tags, languages and taglines | `toolbelt search kernel` |
| `toolbelt show <id>` | detailed view of one toolkit | `toolbelt show dsh-plugins` |
| `toolbelt run <id> [-- args]` | run a bundled tool | `toolbelt run portscan -- host 1-1024` |
| `toolbelt open <id>` | open a repository URL, or print a tool's entry path | `toolbelt open JMNeXt` |
| `toolbelt categories` | list categories with counts | `toolbelt categories` |
| `toolbelt stats` | catalog statistics | `toolbelt stats --json` |
| `toolbelt doctor` | check bash, catalog and tool entries | `toolbelt doctor` |

All read-only commands accept `--json`; `-c`/`--category` and `-k`/`--kind`
filter lists; `--no-color` disables color.

Environment: `TOOLBELT_ROOT`, `TOOLBELT_CATALOG`, `TOOLBELT_LAYOUT` (`auto` | `wide` | `compact`).

## Catalog

The source of truth is [`catalog/toolkits.ini`](catalog/toolkits.ini); the
tables below are generated from it.

### ⚙ 内置工具箱 · Bundled tools

| id | language | license | what it does |
| --- | --- | --- | --- |
| **portscan** (bundled) | Bash | MPL-2.0 | Parallel TCP port scan in pure bash over /dev/tcp; host, port range and concurrency are all arguments |
| **a64elf** (bundled) | C | MPL-2.0 | Fifteen standalone ARM64 image/ELF analysis commands: ADRP xrefs, pointer tables, function maps, string scans |

### ⌨ Termux 与 DSH · Termux & DSH

| id | language | license | what it does |
| --- | --- | --- | --- |
| [dsh-termux-toolkit](https://github.com/moyingyilang/dsh-termux-toolkit) | JavaScript | MPL-2.0 | Build and run DeepSeek Harness natively on Android/Termux: reproducible source patches, a locally compiled flock addon, a Web UI launcher |
| [dsh-plugins](https://github.com/moyingyilang/dsh-plugins) | TypeScript | MIT | DeepSeek Harness plugins: cross-session send/relay messaging and a global token meter |
| [android-termux-builders4JMNeXt](https://github.com/moyingyilang/android-termux-builders4JMNeXt) | Shell | MPL-2.0 | Build Android and Compose Desktop projects from Termux via a Linux container: mount self-check, release-only R8 builds, artifact verification |

### 🔍 Android 逆向 · Android reversing

| id | language | license | what it does |
| --- | --- | --- | --- |
| [Fuck4DuerOS](https://github.com/moyingyilang/Fuck4DuerOS) | Shell | AGPL-3.0 | Modules and apps that optimize DuerOS on Baidu student phones and strip Baidu's control |
| [EFML4A-docs](https://github.com/moyingyilang/EFML4A-docs) | C | GPL-3.0 | Public EFML4A docs: reversing the container format of an Android mod loader for Arknights: Endfield, plus a from-scratch C toolchain |
| [Zygisk-Il2CppDumper](https://github.com/moyingyilang/Zygisk-Il2CppDumper) | C | MIT | Dump il2cpp data at runtime with Zygisk (fork of the upstream project) |

### 🔧 刷机与内核 · Flashing & kernels

| id | language | license | what it does |
| --- | --- | --- | --- |
| [android_kernel_XiaoDu_RMX3511](https://github.com/moyingyilang/android_kernel_XiaoDu_RMX3511) | C | Other | ums9230 kernel development source tree for Xiaodu SEED-2301 (xps06e) |
| [kernel_mi845_lineage](https://github.com/moyingyilang/kernel_mi845_lineage) | C | Other | LineageOS kernel source tree for Snapdragon 845 (mi845) |

### 📚 漫画阅读 · Comic readers

| id | language | license | what it does |
| --- | --- | --- | --- |
| [JMNeXt](https://github.com/moyingyilang/JMNeXt) | Kotlin | AGPL-3.0 | JMComic rewritten in Kotlin, with stability and simplicity as the priorities |
| [JMNeXt4QtDesktop](https://github.com/moyingyilang/JMNeXt4QtDesktop) | C++ | AGPL-3.0 | Native desktop reimplementation of JMNeXt in C++/Qt: discovery, listings, reader, caching all working |
| [MultiComiX](https://github.com/moyingyilang/MultiComiX) | Kotlin | AGPL-3.0 | Multi-source comic reader for Android in Kotlin |
| [JMComic_SRC](https://github.com/moyingyilang/JMComic_SRC) | TypeScript | No license | Source code extracted from JMComic3 as reference material for optimizing JM3-based projects |

### 🤖 游戏自动化 · Game automation

| id | language | license | what it does |
| --- | --- | --- | --- |
| [MaaAzure](https://github.com/moyingyilang/MaaAzure) | Rust | AGPL-3.0 | Azur Lane automation on the MaaFramework stack with zero Python, rewritten from AzurPilot |

### 🌐 站点与 Web · Sites & web

| id | language | license | what it does |
| --- | --- | --- | --- |
| [moyingyilang.github.io](https://github.com/moyingyilang/moyingyilang.github.io) | MDX | AGPL-3.0 | Personal website with MDX content |
| [NT-s_Website_Next](https://github.com/moyingyilang/NT-s_Website_Next) | Go | GPL-3.0 | A website built for a friend, source of the Go rewrite |
| [nt.github.io](https://github.com/moyingyilang/nt.github.io) | HTML | No license | Early website source built for a friend |

## Bundled tools

### portscan

Parallel TCP connect scan over bash's `/dev/tcp`. Host, port range, concurrency
and timeout are arguments — the original local script hard-coded the target.

```bash
tools/portscan/run.sh 192.168.1.1 1-1024
toolbelt run portscan -- 127.0.0.1 8000-8100 -q
```

### a64elf

Fifteen standalone ARM64 image / ELF analysis commands (ADRP cross-references,
pointer tables, function maps, call graphs, string scans). Any C compiler works;
the build is incremental and output goes to `tools/a64elf/bin/`.

```bash
tools/a64elf/build.sh
tools/a64elf/run.sh list
tools/a64elf/run.sh findptr image.bin 0x8a000040
toolbelt run a64elf -- basefind uboot.img
```

## Layout

```text
toolbelt/
├── toolbelt                     # the whole program: TUI + CLI (bash)
├── catalog/toolkits.ini   # categories and toolkits
├── tools/                 # bundled, general-purpose tools
│   ├── portscan/          # bash
│   └── a64elf/            # C sources + build.sh
├── docs/adding-a-toolkit.md
└── tests/run.sh           # catalog, CLI and tool tests
```

## Adding a toolkit

The catalog is an INI file validated on every load. Add a section and the TUI,
the CLI and the tests pick it up:

```ini
[toolkit my-tool]
kind=repo
category=termux
name=my-tool
language=Shell
license=MIT
status=active
url=https://github.com/moyingyilang/my-tool
tags=termux,cli
zh=一句话说明它做什么
en=One sentence about what it does
```

See [`docs/adding-a-toolkit.md`](docs/adding-a-toolkit.md) for bundled tools and
new categories.

## Development

```bash
bash tests/run.sh        # CLI, catalog validation, portscan and a64elf smoke tests
./toolbelt doctor
```

## License

[Mozilla Public License 2.0](LICENSE).

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
