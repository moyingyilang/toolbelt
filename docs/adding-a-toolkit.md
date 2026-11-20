# Adding a tool

Tools live in a tree and the tree *is* the taxonomy:

```text
tools/<category>/<tool>/
├── run.sh            # required entry point
└── README.md         # recommended
```

[`catalog/toolkits.ini`](../catalog/toolkits.ini) only adds the labels and usage
lines the UI needs; it never decides where a tool lives. The `path` field must
name the directory and `entry` the script, and `category` must match a
`[category <id>]` section.

## Add a tool

1. Create the directory:

   ```bash
   mkdir -p tools/net/my-tool
   $EDITOR tools/net/my-tool/run.sh
   ```

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   printf 'hello from my-tool\n'
   ```

   ```bash
   chmod +x tools/net/my-tool/run.sh
   ```

2. Append a catalog section:

   ```ini
   [toolkit my-tool]
   category=net
   name=my-tool
   language=Bash
   license=MPL-2.0
   status=active
   path=tools/net/my-tool
   entry=tools/net/my-tool/run.sh
   tags=network,example
   usage=toolbelt run my-tool -- --help
   zh=一句话说明它做什么
   en=One sentence about what it does
   ```

3. Add `tools/net/my-tool/README.md` and a test in
   [`tests/run.sh`](../tests/run.sh).
4. Verify:

   ```bash
   ./toolbelt doctor
   ./toolbelt run my-tool -- --help
   bash tests/run.sh
   ```

Rules enforced by the parser:

- `id` (the section name) is unique and is the argument to
  `toolbelt show <id>` and `toolbelt run <id>`.
- `category` must match a `[category <id>]` section.
- `status` is `active`, `maintained`, `archived` or `fork`.
- `name`, `language`, `license`, `tags`, `path`, `entry`, `zh` and `en` are
  required; `usage` is optional.
- Unknown keys and unknown sections are errors, so typos fail loudly.

## Add a category

A category is a directory plus a catalog section:

```ini
[category audio]
zh=音频工具
en=Audio tools
icon=♪
blurb=One line for the category bar
```

Then create `tools/audio/` and put tools below it. Categories render in file
order in the TUI and in grouped CLI output.
