# a64elf

Fifteen small ARM64 image / ELF analysis commands. Each one is a single C file
with its own `main`, reads a raw image from disk and prints matches — no
libraries, no state between runs.

They were written while reversing an Android/vendor firmware and used to carry
hard-coded paths and offsets. Here they take the image path and the relevant
addresses as arguments, so the same commands work on any AArch64 image.

## Build and run

```bash
tools/a64elf/build.sh          # incremental build into tools/a64elf/bin/
tools/a64elf/run.sh list       # list commands
tools/a64elf/run.sh findptr image.bin 0x8a000040
```

Through `toolbelt`:

```bash
toolbelt run a64elf                       # build + list
toolbelt run a64elf -- build              # rebuild
toolbelt run a64elf -- basefind uboot.img
```

The build needs only a C compiler (`cc`/`clang`/`gcc` via `$CC`). `bin/` is
git-ignored.

## Commands

Addresses are hexadecimal offsets/addresses as shown by your loader or by the
tools' own output.

| command | what it does | arguments |
| --- | --- | --- |
| `adrp_xref` | Wide ARM64 ADRP cross-reference scan: find ADD/LDR that materialize a target | `<image> <off_hex>...` |
| `basecheck` | For each candidate base, count pointer-like 8-byte values that reference printable strings | `<image> <base_hex>...` |
| `basefind` | Solve the real load base of a U-Boot payload by bucketing pointer/string deltas | `<image>` |
| `callgraph` | Scan `BL`/`B imm26` and emit call edges plus a call-count table | `<image> <base_hex> [target_hex]` |
| `dstr` | Dump the NUL-terminated strings referenced from given addresses | `<image> <base_hex> <addr_hex>...` |
| `dumptbl` | Dump a table of pointers at an address, with optional item count | `<image> <base_hex> <table_hex> [count]` |
| `findptr` | Find 8-byte absolute pointers in an image (locate pointer tables) | `<image> <target_hex>...` |
| `findref` | Find instructions that reference an absolute address (ADRP+ADD/LDR/STR) | `<image> <base_hex> <target_hex>...` |
| `findtables` | Find runs of consecutive function pointers (`initcall`/command tables) | `<image> <base_hex> [min_run]` |
| `findval` | Find a 32-bit value as raw little-endian data and as `movz`/`movk` immediates | `<image> <base_hex> <value_hex>...` |
| `fnstr` | List strings referenced by ADRP+ADD inside an address range | `<image> <base_hex> <start_hex> [end_hex]` |
| `funcmap` | Scan function prologues and guess each function's purpose from referenced strings | `<image> <base_hex> [min_fn_bytes]` |
| `patchuboot` | Patch a U-Boot image so normal mode also runs the mode-probe chain | `<in.img> <out.img>` |
| `uboot_scan` | Unisoc (Spreadtrum) U-Boot / DHTB image analyzer | `<image> [target_string...]` |
| `xref_hist` | Histogram of ADRP+ADD target addresses | `<image>` |

Run any command without arguments to print its usage line.

## Caveats

- These are analysis helpers, not a loader or a disassembler. They assume a
  little-endian AArch64 image and a known load base for address-based commands.
- `patchuboot` writes a new image; it never edits the input in place.
