# Tools · 工具

Every tool lives in its own directory, grouped by category. The tree is the
taxonomy; [`catalog/toolkits.ini`](../catalog/toolkits.ini) only adds labels,
tags and a usage line for the UI and the CLI.

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

Each tool directory has a `run.sh` entry point:

```bash
./toolbelt run <id> [-- args...]
# which executes tools/<category>/<id>/run.sh with those args
```

| category | tool | language | what it does |
| --- | --- | --- | --- |
| `android` | [`android-build`](android/android-build/) | Bash | Build Gradle Android projects, report or install the APKs |
| `android` | [`apk-info`](android/apk-info/) | Bash | Inspect an APK: hash, ABIs, package identity |
| `net` | [`portscan`](net/portscan/) | Bash | Parallel TCP connect scan over `/dev/tcp` |
| `reverse` | [`a64elf`](reverse/a64elf/) | C | 15 standalone ARM64 image/ELF analysis commands |
| `termux` | [`termux-doctor`](termux/termux-doctor/) | Bash | Check the Termux/Android environment for toolchain traps |

## Adding a tool

1. Create `tools/<category>/<name>/run.sh` (executable) and a README.
2. Add a `[toolkit <name>]` section to `catalog/toolkits.ini` with the matching
   `category`, `path` and `entry`.
3. Add a test to `tests/run.sh`.

See [`docs/adding-a-toolkit.md`](../docs/adding-a-toolkit.md) for the full checklist.
