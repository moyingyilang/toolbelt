# Tools · 工具

Every tool lives in its own directory, grouped by category. The tree is the
taxonomy; [`catalog/toolkits.ini`](../catalog/toolkits.ini) only adds labels,
tags and a usage line for the UI and the CLI.

```text
tools/
├── android/
│   ├── android-build/
│   └── apk-info/
├── efml/
│   ├── ab-header/
│   └── lz4-block/
├── net/
│   └── portscan/
├── reverse/
│   └── a64elf/
├── termux/
│   └── termux-doctor/
└── toolchain/
    ├── android-sdk-install/
    ├── jdk-install/
    └── toolchain-doctor/
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
| `efml` | [`ab-header`](efml/ab-header/) | C | Verify and unscramble an EFML4A `.ab` header |
| `efml` | [`lz4-block`](efml/lz4-block/) | C | Decode standard or inverted LZ4 blocks |
| `net` | [`portscan`](net/portscan/) | Bash | Parallel TCP connect scan over `/dev/tcp` |
| `reverse` | [`a64elf`](reverse/a64elf/) | C | 15 standalone ARM64 image/ELF analysis commands |
| `termux` | [`termux-doctor`](termux/termux-doctor/) | Bash | Check the Termux/Android environment for toolchain traps |
| `toolchain` | [`android-sdk-install`](toolchain/android-sdk-install/) | Bash | Install the Android command-line SDK into one directory |
| `toolchain` | [`jdk-install`](toolchain/jdk-install/) | Bash | Download and verify a Temurin JDK |
| `toolchain` | [`toolchain-doctor`](toolchain/toolchain-doctor/) | Bash | Check JDK/SDK/NDK/C/Rust/Go/Node/Python with install hints |

## Adding a tool

1. Create `tools/<category>/<name>/run.sh` (executable) and a README.
2. Add a `[toolkit <name>]` section to `catalog/toolkits.ini` with the matching
   `category`, `path` and `entry`.
3. Add a test to `tests/run.sh`.

See [`docs/adding-a-toolkit.md`](../docs/adding-a-toolkit.md) for the full checklist.
