# EFML · 夭折的 EFML4A

EFML4A was an Android mod loader for *Arknights: Endfield* — a research project
that reached a working understanding of the VFS (`.blc` index + `.chk` data),
the `.ab` container, its two LZ4 variants and the anti-tamper write chain, and
then stopped before shipping. The public notes live in
[EFML4A-docs](https://github.com/moyingyilang/EFML4A-docs): container layout,
crypto, compression, texture formats, the write chain and the runtime probes.

These tools preserve the reusable half of that research as small, standalone
commands that do not need the rest of the project:

| tool | what it does |
| --- | --- |
| [`ab-header`](ab-header/) | Verify and unscramble the 48-byte `.ab` header |
| [`lz4-block`](lz4-block/) | Decode standard or inverted LZ4 blocks |

Both are plain C, compiled on first use, and each has a `--selftest` that
exercises the format logic without needing a sample container.

The format knowledge is documented at
[`EFML4A-docs`](https://github.com/moyingyilang/EFML4A-docs) — in particular
`A2-ab-container.md` for the header and `A4-compression.md` for the two LZ4
variants.
