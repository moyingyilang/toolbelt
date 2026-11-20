# ab-header

Inspect the 48-byte obfuscated header of an EFML4A `.ab` container without
decrypting anything. It verifies the self-check pair, unscrambles the six
fields (`compBI`, `uncompBI`, `size`, `flags`, `encFlags`), and reports where
the compression block info and the data blocks start.

This is the header half of the EFML4A research toolchain, taken from the
project's `abtool`/`abverify` sources and the public notes in
[EFML4A-docs](https://github.com/moyingyilang/EFML4A-docs) (`A2-ab-container.md`).

```bash
tools/efml/ab-header/run.sh bundle.ab
tools/efml/ab-header/run.sh bundle.ab --json
tools/efml/ab-header/run.sh --selftest
toolbelt run ab-header -- bundle.ab
```

Output:

```text
file        bundle.ab
bytes       9806
self-check  ok
compBI      101
uncompBI    4096
size        208000000
flags       0x00000005
encFlags    7
block info  @48
data        @160
```

`self-check ok` means the file's first 8 bytes satisfy the provider's quick
check. A mismatch means it is not an EFML4A `.ab`, or it is damaged.

The obfuscation constants and field pairings are documented in the EFML4A
notes; `--selftest` re-derives a header from known field values and parses it
back, so the formulas are exercised without needing a sample file.

The tool is built on first use with any C compiler; the binary lands in
`bin/` (git-ignored).
