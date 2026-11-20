# Toolbelt

**All the tools, one belt.**

A terminal-only toolbox. Every tool lives in its own directory under
`tools/<category>/<name>/` — the tree *is* the taxonomy — and `toolbelt`
browses that tree in a TUI or runs a tool from the CLI. One bash script: no
build step, no runtime dependencies beyond bash and coreutils. Linux and
Termux only: no GUI, no website, no Windows.

English | [中文](README.zh.md)

[![bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](toolbelt)
[![Linux + Termux](https://img.shields.io/badge/platform-Linux%20%2B%20Termux-4D6BFE?style=flat-square)](toolbelt)
[![License: MPL-2.0](https://img.shields.io/badge/license-MPL--2.0-blue?style=flat-square)](LICENSE)
[![TUI + CLI](https://img.shields.io/badge/mode-TUI%20%2B%20CLI-orange?style=flat-square)](toolbelt)

> **Status: 0.4 preview.** Five tools, four categories, TUI and CLI are working;
> the belt keeps growing.

## What it is

- **A tree of tools** — `tools/<category>/<name>/run.sh` is the entry point.
  Categories are directories: `android`, `net`, `reverse`, `termux`.
- **A catalog with labels** — [`catalog/toolkits.ini`](catalog/toolkits.ini)
  adds the Chinese/English names, tags, license and usage line that the UI
  needs. No repository index: this repo *is* the tools.
- **A TUI** — `toolbelt` with no arguments. Browse, search, read the usage line,
  run a tool without leaving the terminal.
- **A CLI** — `toolbelt list`, `search`, `show`, `run`, `categories`, `stats`,
  `doctor`, all with `--json`. Same program, two modes.

## Tree

```text
tools/
├── android/
│   ├── android-build/
│   └── apk-info/
├── net/
│   └── portscan/
├── reverse/
│   └── a64elf/
└── termux/
    └── termux-doctor/
```

Adding a tool means adding a directory here plus one catalog section; the TUI,
the CLI and the tests pick it up.

## Preview

On a phone terminal (50 columns, stacked layout):

```text
┌ Toolbelt ────────────────────────────── 5 kits ┐
│ ★ 全部 · 5  (←→ 分类)                          │
├────────────────────────────────────────────────┤
│▸ ⚙ portscan                                    │
│  ⚙ a64elf                                      │
│  ⚙ android-build                               │
│  ⚙ apk-info                                    │
│  ⚙ termux-doctor                               │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
├────────────────────────────────────────────────┤
│portscan                                        │
│● active · Bash                                 │
│license: MPL-2.0                                │
│category: 网络                                  │
└────────────────────────────────────────────────┘
 ↑↓ ←→ ⏎ / ? q
```

On a desktop terminal (100 columns, three panes):

```text
┌ Toolbelt ───────────────────────────────────────────────────────────── 5 toolkits · 4 categories ┐
│ Categories         │ ★ 全部 (5)                     │ Details                                    │
│★ 全部             5│▸ ⚙ portscan                    │portscan                                    │
│🌐 网络            1│  ⚙ a64elf                      │● active · Bash                             │
│🔍 逆向            1│  ⚙ android-build               │license: MPL-2.0                            │
│📱 Android 构建    2│  ⚙ apk-info                    │category: 网络                              │
│⌨ Termux 环境      1│  ⚙ termux-doctor               │tags: network,tcp,termux                    │
│                    │                                │                                            │
│                    │                                │并行 TCP 端口扫描：纯 bash +                │
│                    │                                │/dev/tcp，主机、端口区间、并发度全部参数化  │
│                    │                                │                                            │
│                    │                                │Parallel TCP port scan in pure bash over    │
│                    │                                │/dev/tcp; host, port range and concurrency  │
│                    │                                │are arguments                               │
│                    │                                │                                            │
│                    │                                │entry: tools/net/portscan/run.sh            │
│                    │                                │                                            │
│                    │                                │usage: toolbelt run portscan -- 192.168.1.1 │
│                    │                                │1-1024 --jobs 128                           │
│                    │                                │                                            │
│                    │                                │[r] run this tool                           │
│                    │                                │                                            │
│                    │                                │                                            │
│                    │                                │                                            │
│                    │                                │                                            │
│                    │                                │                                            │
│                    │                                │                                            │
│                    │                                │                                            │
└────────────────────┴────────────────────────────────┴────────────────────────────────────────────┘
 ↑↓/jk move · ←→/hl category · ⏎ run · / search · ? help · q quit
```

## Quick start

```bash
git clone https://github.com/moyingyilang/toolbelt.git
cd toolbelt

./toolbelt                    # TUI
./toolbelt list               # CLI
./toolbelt run termux-doctor  # run a tool
```

On Termux only `git` is needed — bash and coreutils are already there.
To put it on your PATH:

```bash
install -m 0755 toolbelt "$PREFIX/bin/toolbelt"     # Termux
install -m 0755 toolbelt ~/.local/bin/toolbelt      # generic Linux
```

The script finds its catalog next to itself, so `catalog/` and `tools/` must
stay beside `toolbelt`.

## Responsive by default

| terminal width | layout |
| --- | --- |
| `>= 92` columns | three panes: categories / tools / details |
| `< 92` columns | stacked: category bar, tool list, details below |

Force one with `TOOLBELT_LAYOUT=wide` or `TOOLBELT_LAYOUT=compact`.

## TUI keys

| key | action |
| --- | --- |
| `↑` `↓` / `k` `j` | move the selection |
| `←` `→` / `h` `l` / `Tab` | previous / next category |
| `PgUp` `PgDn` / `g` `G` | first / last tool |
| `/` | search (Enter applies, Esc cancels) |
| `Enter` / `r` | run the selected tool |
| `[` `]` | scroll the detail pane |
| `?` | key help |
| `q` / `Ctrl-C` | quit |

## CLI reference

| command | description | example |
| --- | --- | --- |
| `toolbelt` | open the TUI (lists the catalog off a TTY) | `toolbelt` |
| `toolbelt list` | list tools, grouped by category | `toolbelt list -c android` |
| `toolbelt search <q>` | search ids, names, tags, languages and taglines | `toolbelt search apk` |
| `toolbelt show <id>` | detailed view of one tool | `toolbelt show android-build` |
| `toolbelt run <id> [-- args]` | run a tool | `toolbelt run portscan -- host 1-1024` |
| `toolbelt categories` | list categories with counts | `toolbelt categories` |
| `toolbelt stats` | catalog statistics | `toolbelt stats --json` |
| `toolbelt doctor` | check bash, catalog and tool entries | `toolbelt doctor` |

All read-only commands accept `--json`; `-c`/`--category` filters lists and
`--no-color` disables color.

Environment: `TOOLBELT_ROOT`, `TOOLBELT_CATALOG`, `TOOLBELT_LAYOUT`
(`auto` | `wide` | `compact`).

## Tools

The source of truth is [`catalog/toolkits.ini`](catalog/toolkits.ini); the
tables below are generated from it.

### 🌐 网络 · Network

| tool | language | what it does |
| --- | --- | --- |
| **portscan** | Bash | Parallel TCP port scan in pure bash over /dev/tcp; host, port range and concurrency are arguments |

### 🔍 逆向 · Reverse engineering

| tool | language | what it does |
| --- | --- | --- |
| **a64elf** | C | Fifteen standalone ARM64 image/ELF analysis commands: ADRP xrefs, pointer tables, function maps, string scans |

### 📱 Android 构建 · Android build

| tool | language | what it does |
| --- | --- | --- |
| **android-build** | Bash | Build a Gradle Android project from the terminal: detect the JDK and SDK, run assemble<Variant>, report new APK size and SHA-256, optionally adb install |
| **apk-info** | Bash | Inspect an APK: size, SHA-256, native ABIs and v1 signature evidence, plus package identity when aapt2/aapt is available |

### ⌨ Termux 环境 · Termux environment

| tool | language | what it does |
| --- | --- | --- |
| **termux-doctor** | Bash | Check a Termux/Android environment: link(2) limits, Node heap, locale, storage permissions, adb/JDK/Android SDK |

## Adding a tool

Create `tools/<category>/<name>/run.sh` and add a section to the catalog:

```ini
[toolkit my-tool]
category=android
name=my-tool
language=Bash
license=MPL-2.0
status=active
path=tools/android/my-tool
entry=tools/android/my-tool/run.sh
tags=android,build
usage=toolbelt run my-tool -- --help
zh=一句话说明它做什么
en=One sentence about what it does
```

The directory tree and the catalog must agree: `path` names the directory and
`entry` the script. See [`docs/adding-a-toolkit.md`](docs/adding-a-toolkit.md).

## Layout

```text
toolbelt/
├── toolbelt                     # the whole program: TUI + CLI (bash)
├── catalog/toolkits.ini         # labels and usage lines for the tree
├── tools/<category>/<name>/     # the tools themselves
│   └── run.sh                   # every tool's entry point
├── docs/adding-a-toolkit.md
└── tests/run.sh                 # catalog, CLI and tool tests
```

## Development

```bash
bash tests/run.sh        # catalog validation, CLI, TUI fallback, every bundled tool
./toolbelt doctor
```

## License

[Mozilla Public License 2.0](LICENSE).

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
