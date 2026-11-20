# Toolbelt

**所有工具，一条腰带。**

一个只在终端里活的工具箱。每个工具都有自己的目录 `tools/<分类>/<名字>/`——
树本身就是分类——`toolbelt` 用 TUI 浏览这棵树，也可以直接从 CLI 运行。整个程序
是一个 bash 脚本：不用编译，除 bash 和 coreutils 外没有运行时依赖。只支持
Linux / Termux：没有 GUI，没有网站，不支持 Windows。

[English](README.md) | 中文

[![bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](toolbelt)
[![Linux + Termux](https://img.shields.io/badge/platform-Linux%20%2B%20Termux-4D6BFE?style=flat-square)](toolbelt)
[![License: MPL-2.0](https://img.shields.io/badge/license-MPL--2.0-blue?style=flat-square)](LICENSE)
[![TUI + CLI](https://img.shields.io/badge/mode-TUI%20%2B%20CLI-orange?style=flat-square)](toolbelt)

> **状态：0.5 预览版。** 10 个工具、6 个分类，TUI 和 CLI 都已可用，腰带还会继续加长。

## 它是什么

- **一棵工具树** —— `tools/<分类>/<名字>/run.sh` 就是入口，分类就是目录：
  `android`、`efml`、`net`、`reverse`、`toolchain`、`termux`。
- **一份只存标签的目录** —— [`catalog/toolkits.ini`](catalog/toolkits.ini) 只提供
  中英文名、标签、许可证和用法行，给界面用。不做仓库索引：这个仓库本身就是工具。
- **一个 TUI** —— 不带参数运行 `toolbelt`，在终端里浏览、搜索、看用法、直接运行。
- **一个 CLI** —— `toolbelt list`、`search`、`show`、`run`、`categories`、`stats`、
  `doctor`，全部支持 `--json`。同一个程序，两种形态。

## 目录树

```text
┌ Toolbelt ───────────────────────────── 10 kits ┐
│ ★ 全部 · 10  (←→ 分类)                         │
├────────────────────────────────────────────────┤
│▸ ⚙ portscan                                    │
│  ⚙ a64elf                                      │
│  ⚙ ab-header                                   │
│  ⚙ lz4-block                                   │
│  ⚙ android-build                               │
│  ⚙ apk-info                                    │
│  ⚙ toolchain-doctor                            │
│  ⚙ android-sdk-install                         │
│  ⚙ jdk-install                                 │
│  ⚙ termux-doctor                               │
├────────────────────────────────────────────────┤
│portscan                                        │
│● active · Bash                                 │
│license: MPL-2.0                                │
│category: 网络                                  │
└────────────────────────────────────────────────┘
 ↑↓ ←→ ⏎ / ? q
```

加一个工具 = 加一个目录 + 一节 catalog，TUI、CLI 和测试都会自动识别。

## 预览

手机终端（50 列，上下堆叠布局）：

```text
┌ Toolbelt ──────────────────────────────────────────────────────────── 10 toolkits · 6 categories ┐
│ Categories         │ ★ 全部 (10)                    │ Details                                    │
│★ 全部            10│▸ ⚙ portscan                    │portscan                                    │
│🌐 网络            1│  ⚙ a64elf                      │● active · Bash                             │
│🔍 逆向            1│  ⚙ ab-header                   │license: MPL-2.0                            │
│🧩 EFML 容器       2│  ⚙ lz4-block                   │category: 网络                              │
│📱 Android 构建    2│  ⚙ android-build               │tags: network,tcp,termux                    │
│🛠 构建工具链      3│  ⚙ apk-info                    │                                            │
│⌨ Termux 环境      1│  ⚙ toolchain-doctor            │并行 TCP 端口扫描：纯 bash +                │
│                    │  ⚙ android-sdk-install         │/dev/tcp，主机、端口区间、并发度全部参数化  │
│                    │  ⚙ jdk-install                 │                                            │
│                    │  ⚙ termux-doctor               │Parallel TCP port scan in pure bash over    │
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

桌面终端（100 列，三栏布局）：

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

## 快速开始

```bash
git clone https://github.com/moyingyilang/toolbelt.git
cd toolbelt

./toolbelt                    # TUI
./toolbelt list               # CLI
./toolbelt run termux-doctor  # 跑一个工具
```

Termux 上只需要装 `git`——bash 和 coreutils 本来就是自带的。放进 PATH：

```bash
install -m 0755 toolbelt "$PREFIX/bin/toolbelt"     # Termux
install -m 0755 toolbelt ~/.local/bin/toolbelt      # 一般 Linux
```

脚本会在自己旁边找 catalog，所以 `catalog/` 和 `tools/` 要和 `toolbelt` 放同一目录。

## 默认响应式

| 终端宽度 | 布局 |
| --- | --- |
| `>= 92` 列 | 三栏：分类 / 工具 / 详情 |
| `< 92` 列 | 上下堆叠：分类栏、工具列表、详情 |

可以用 `TOOLBELT_LAYOUT=wide|compact` 强制。

## TUI 按键

| 按键 | 作用 |
| --- | --- |
| `↑` `↓` / `k` `j` | 上下移动选择 |
| `←` `→` / `h` `l` / `Tab` | 上一个 / 下一个分类 |
| `PgUp` `PgDn` / `g` `G` | 第一个 / 最后一个工具 |
| `/` | 搜索（回车应用，Esc 取消） |
| `Enter` / `r` | 运行选中的工具 |
| `[` `]` | 滚动详情 |
| `?` | 按键帮助 |
| `q` / `Ctrl-C` | 退出 |

## CLI 参考

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `toolbelt` | 打开 TUI（非 TTY 时退化为列表） | `toolbelt` |
| `toolbelt list` | 按分类列出工具 | `toolbelt list -c android` |
| `toolbelt search <q>` | 搜索 id、名称、标签、语言、描述 | `toolbelt search apk` |
| `toolbelt show <id>` | 查看单个工具详情 | `toolbelt show android-build` |
| `toolbelt run <id> [-- 参数]` | 运行工具 | `toolbelt run portscan -- host 1-1024` |
| `toolbelt categories` | 列出分类与数量 | `toolbelt categories` |
| `toolbelt stats` | 目录统计 | `toolbelt stats --json` |
| `toolbelt doctor` | 自检 bash、目录与工具入口 | `toolbelt doctor` |

所有只读命令支持 `--json`；`-c`/`--category` 过滤列表，`--no-color` 关闭颜色。

环境变量：`TOOLBELT_ROOT`、`TOOLBELT_CATALOG`、`TOOLBELT_LAYOUT`
（`auto` | `wide` | `compact`）。

## 工具

唯一数据源是 [`catalog/toolkits.ini`](catalog/toolkits.ini)，下面的表格由它生成。

### 🌐 网络 · Network

| tool | language | what it does |
| --- | --- | --- |
| **portscan** | Bash | Parallel TCP port scan in pure bash over /dev/tcp; host, port range and concurrency are arguments |

### 🔍 逆向 · Reverse engineering

| tool | language | what it does |
| --- | --- | --- |
| **a64elf** | C | Fifteen standalone ARM64 image/ELF analysis commands: ADRP xrefs, pointer tables, function maps, string scans |

### 🧩 EFML 容器 · EFML containers

| tool | language | what it does |
| --- | --- | --- |
| **ab-header** | C | Verify and unscramble an EFML4A .ab header: self-check, compBI/uncompBI/size/flags/encFlags, block-info and data offsets |
| **lz4-block** | C | Decode one raw LZ4 block, standard or the big-endian-offset inverted variant (LZ4Inv), with --selftest |

### 📱 Android 构建 · Android build

| tool | language | what it does |
| --- | --- | --- |
| **android-build** | Bash | Build a Gradle Android project from the terminal: detect the JDK and SDK, run assemble<Variant>, report new APK size and SHA-256, optionally adb install |
| **apk-info** | Bash | Inspect an APK: size, SHA-256, native ABIs and v1 signature evidence, plus package identity when aapt2/aapt is available |

### 🛠 构建工具链 · Build toolchain

| tool | language | what it does |
| --- | --- | --- |
| **toolchain-doctor** | Bash | Check a build toolchain in one pass: JDK/Gradle/Android SDK/NDK, C/CMake/zlib, Rust/Go/Node/Python, with install hints |
| **android-sdk-install** | Bash | Install the Android command-line SDK into one directory: cmdline-tools, licenses, platform-tools/build-tools/platform, optional NDK |
| **jdk-install** | Bash | Download, verify and extract a Temurin JDK from the Adoptium API into a user directory, printing JAVA_HOME/PATH |

### ⌨ Termux 环境 · Termux environment

| tool | language | what it does |
| --- | --- | --- |
| **termux-doctor** | Bash | Check a Termux/Android environment: link(2) limits, Node heap, locale, storage permissions, adb/JDK/Android SDK |

### EFML4A 的遗产

`efml` 分类保留了夭折的 EFML4A 项目里可复用的那一半：`ab-header` 校验并解扰
`.ab` 头，`lz4-block` 解码两种 LZ4 变体。格式笔记公开在
[EFML4A-docs](https://github.com/moyingyilang/EFML4A-docs)。两个工具都带
`--selftest`，首次运行按需编译。

## 添加工具

建 `tools/<分类>/<名字>/run.sh`，再往 catalog 加一节：

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

目录树和 catalog 必须一致：`path` 指目录，`entry` 指脚本。详见
[`docs/adding-a-toolkit.md`](docs/adding-a-toolkit.md)。

## 目录结构

```text
toolbelt/
├── toolbelt                     # 整个程序：TUI + CLI（bash）
├── catalog/toolkits.ini         # 工具树的标签与用法行
├── tools/<分类>/<名字>/          # 工具本体
│   └── run.sh                   # 每个工具的入口
├── docs/adding-a-toolkit.md
└── tests/run.sh                 # 目录、CLI 与工具测试
```

## 开发

```bash
bash tests/run.sh        # 目录校验、CLI、TUI 回退、所有内置工具
./toolbelt doctor
```

## 许可证

[Mozilla Public License 2.0](LICENSE)。

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
