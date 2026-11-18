# Adding a toolkit

[`catalog/toolkits.ini`](../catalog/toolkits.ini) is the single source of truth.
`toolbelt`, the README tables and the tests all read it, and it is validated on
every load.

## Add an external repository

Append a section at the end of the file:

```ini
[toolkit my-project]
kind=repo
category=termux
name=my-project
language=Go
license=MIT
status=active
url=https://github.com/moyingyilang/my-project
tags=termux,cli
zh=一句话说明它做什么
en=One sentence about what it does
```

Rules enforced by the parser:

- `id` (the section name) is unique across categories and toolkits, and is the
  argument to `toolbelt show <id>`.
- `category` must match a `[category <id>]` section.
- `kind` is `repo` or `tool`; `status` is `active`, `maintained`, `archived` or
  `fork`.
- `name`, `language`, `license`, `tags`, `zh` and `en` are required.
- A `repo` needs `url`; a `tool` needs `path` and `entry`.
- Unknown keys and unknown sections are errors, so typos fail loudly.

## Add a bundled tool

1. Create `tools/<id>/` with a `run.sh` entry point:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   cd "$(dirname "$0")"
   exec ./my-tool "$@"
   ```

2. Add a catalog section with `kind=tool`, `path=tools/<id>` and
   `entry=tools/<id>/run.sh`, plus an optional `usage=` line.
3. Add `tools/<id>/README.md` and a test in [`tests/run.sh`](../tests/run.sh).
4. Run `./toolbelt doctor` — it fails when a tool entry file is missing.

Bundled tools stay dependency-light. When one needs a compiler (like
`a64elf`), let `run.sh` build on first use and add the build output to
`.gitignore`.

## Add a category

```ini
[category audio]
zh=音频工具
en=Audio tools
icon=♪
blurb=One line for the category bar
```

Categories render in file order in the TUI and in grouped CLI output.

## Verify

```bash
bash tests/run.sh
./toolbelt doctor
./toolbelt list
```
