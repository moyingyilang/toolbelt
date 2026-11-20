# lz4-block

Decode one raw LZ4 block in either variant the game uses:

- **standard** — the block-info table (little-endian match offsets)
- **inverted** (`--inv`) — data blocks (big-endian offsets, bit-interleaved
  token layout, called "LZ4Inv" in the EFML4A notes)

```bash
tools/efml/lz4-block/run.sh block.bin out.bin 131072
tools/efml/lz4-block/run.sh block.bin out.bin 131072 --inv
tools/efml/lz4-block/run.sh --selftest
toolbelt run lz4-block -- block.bin out.bin 131072 --inv
```

```text
usage: lz4-block <input> <output> <uncompressed-size> [--inv]
```

There is no end marker and no size inside an LZ4 block — zero padding a
compressed stream corrupts it, because `0x00` decodes as a zero-length match
with offset zero. That is why the uncompressed size is required and the output
capacity is never exceeded.

The decoder follows the EFML4A toolchain's `lz4d()` from `abtool.c`, rewritten
as a standalone tool with bounds checks on every read and every match.

`--selftest` exercises both variants with literal-only and match sequences.

The tool is built on first use with any C compiler; the binary lands in
`bin/` (git-ignored).
