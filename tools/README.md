# Bundled tools · 内置工具

These are the toolkits that live **in this repository**. They started as local,
device-specific scratch scripts and were generalized so they run anywhere bash
or a C compiler is available.

`tools/` is intentionally small and dependency-free: every entry is either a
POSIX-ish shell script or a single-file C program. `toolbelt run <id>` builds them
on first use when a build step is required.

| id | language | what it does |
| --- | --- | --- |
| [`portscan`](portscan/) | Bash | Parallel TCP connect scan over `/dev/tcp` |
| [`a64elf`](a64elf/) | C | 15 standalone ARM64 image/ELF analysis commands |

## Adding a tool

1. Put it in `tools/<id>/` with a `run.sh` entry point (or a build script that
   this entry point drives).
2. Add an entry with `"kind": "tool"` to [`catalog/toolkits.json`](../catalog/toolkits.json).
3. Add a short README and a test under `test/`.

See [`docs/adding-a-toolkit.md`](../docs/adding-a-toolkit.md) for the full checklist.
