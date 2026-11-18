# Toolbelt

**所有工具箱，一条腰带。**

一个只在终端里活的工具箱合集：TUI 浏览、CLI 脚本化、外加几个开箱即用的内置工具。
整个程序是一个 bash 脚本——不用编译、没有运行时依赖，只要有 bash 和 coreutils。
只支持 Linux / Termux：没有 GUI，没有网站，不支持 Windows。

[English](README.md) | 中文

[![bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](toolbelt)
[![Linux + Termux](https://img.shields.io/badge/platform-Linux%20%2B%20Termux-4D6BFE?style=flat-square)](toolbelt)
[![License: MPL-2.0](https://img.shields.io/badge/license-MPL--2.0-blue?style=flat-square)](LICENSE)
[![TUI + CLI](https://img.shields.io/badge/mode-TUI%20%2B%20CLI-orange?style=flat-square)](toolbelt)

> **状态：0.2 预览版。** TUI、CLI、响应式布局和内置工具都已可用，工具集还在持续补充。

## 它是什么

- **一份目录** —— 7 个分类、18 个工具集，写在
  [`catalog/toolkits.ini`](catalog/toolkits.ini) 里。只收录公开仓库；
  本机那些高度特化的工具会被通用化后放进 [`tools/`](tools/)。
- **一个 TUI** —— 不带参数运行 `toolbelt`，在终端里浏览、搜索、打开仓库或运行内置工具。
- **一个 CLI** —— `toolbelt list`、`search`、`show`、`run`、`open`、`categories`、
  `stats`、`doctor`，全部支持 `--json`。同一个程序，两种形态。
- **内置工具** —— [`portscan`](tools/portscan/) 和
  [`a64elf`](tools/a64elf/)：从本机脚本通用化而来的便携版本。

## 预览

手机终端（50 列，上下堆叠布局）：

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

桌面终端（100 列，三栏布局）：

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

## 快速开始

```bash
git clone https://github.com/moyingyilang/toolbelt.git
cd toolbelt

./toolbelt          # TUI
./toolbelt list     # CLI
./toolbelt show portscan
```

Termux 上只需要装 `git`——bash 和 coreutils 本来就是自带的。
想放进 PATH：

```bash
install -m 0755 toolbelt "$PREFIX/bin/toolbelt"     # Termux
install -m 0755 toolbelt ~/.local/bin/toolbelt      # 一般 Linux
```

脚本会在自己旁边找 `catalog/`，所以 `catalog/` 和 `tools/` 要和 `toolbelt` 放在同一目录。

## 默认响应式

| 终端宽度 | 布局 |
| --- | --- |
| `>= 92` 列 | 三栏：分类 / 工具集 / 详情 |
| `< 92` 列 | 上下堆叠：分类栏、工具列表、详情 |

手机、分屏和窄窗口会自动切到堆叠布局。也可以强制指定：

```bash
TOOLBELT_LAYOUT=compact ./toolbelt   # 在大屏上强制用手机布局
TOOLBELT_LAYOUT=wide ./toolbelt      # 强制三栏
```

## TUI 按键

| 按键 | 作用 |
| --- | --- |
| `↑` `↓` / `k` `j` | 上下移动选择 |
| `←` `→` / `h` `l` / `Tab` | 上一个 / 下一个分类 |
| `PgUp` `PgDn` / `g` `G` | 第一个 / 最后一个 |
| `/` | 搜索（回车应用，Esc 取消） |
| `Enter` | 打开仓库，或运行内置工具 |
| `o` / `r` | 打开仓库地址 / 运行内置工具 |
| `[` `]` | 滚动详情 |
| `?` | 按键帮助 |
| `q` / `Ctrl-C` | 退出 |

## CLI 参考

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `toolbelt` | 打开 TUI（非 TTY 时退化为列表） | `toolbelt` |
| `toolbelt list` | 按分类列出所有工具集 | `toolbelt list -c termux` |
| `toolbelt search <q>` | 搜索 id、名称、标签、语言、描述 | `toolbelt search kernel` |
| `toolbelt show <id>` | 查看单个工具集详情 | `toolbelt show dsh-plugins` |
| `toolbelt run <id> [-- 参数]` | 运行内置工具 | `toolbelt run portscan -- host 1-1024` |
| `toolbelt open <id>` | 打开仓库地址，或输出工具入口路径 | `toolbelt open JMNeXt` |
| `toolbelt categories` | 列出分类与数量 | `toolbelt categories` |
| `toolbelt stats` | 目录统计 | `toolbelt stats --json` |
| `toolbelt doctor` | 自检 bash、目录和工具入口 | `toolbelt doctor` |

所有只读命令都支持 `--json`；`-c`/`--category` 和 `-k`/`--kind` 过滤列表；
`--no-color` 关闭颜色。

环境变量：`TOOLBELT_ROOT`、`TOOLBELT_CATALOG`、`TOOLBELT_LAYOUT`
（`auto` | `wide` | `compact`）。

## 目录

唯一数据源是 [`catalog/toolkits.ini`](catalog/toolkits.ini)，下面的表格由它生成。

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

## 内置工具

### portscan

基于 bash `/dev/tcp` 的并行 TCP 端口扫描。主机、端口区间、并发度和超时全部是参数
——本机原始脚本里目标是写死的。

```bash
tools/portscan/run.sh 192.168.1.1 1-1024
toolbelt run portscan -- 127.0.0.1 8000-8100 -q
```

### a64elf

15 个独立的 ARM64 镜像 / ELF 分析命令（ADRP 交叉引用、指针表、函数图谱、调用图、
字符串扫描等）。任意 C 编译器即可，增量构建，产物在 `tools/a64elf/bin/`。

```bash
tools/a64elf/build.sh
tools/a64elf/run.sh list
tools/a64elf/run.sh findptr image.bin 0x8a000040
toolbelt run a64elf -- basefind uboot.img
```

## 目录结构

```text
toolbelt/
├── toolbelt               # 整个程序：TUI + CLI（bash）
├── catalog/toolkits.ini   # 分类与工具集
├── tools/                 # 内置的通用工具
│   ├── portscan/          # bash
│   └── a64elf/            # C 源码 + build.sh
├── docs/adding-a-toolkit.md
└── tests/run.sh           # 目录、CLI 与工具测试
```

## 添加工具集

目录是 INI 文件，每次加载都会校验。加一节就能被 TUI、CLI 和测试识别：

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

内置工具和新分类的写法见 [`docs/adding-a-toolkit.md`](docs/adding-a-toolkit.md)。

## 开发

```bash
bash tests/run.sh        # CLI、目录校验、portscan 与 a64elf 冒烟测试
./toolbelt doctor
```

## 许可证

[Mozilla Public License 2.0](LICENSE)。

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
