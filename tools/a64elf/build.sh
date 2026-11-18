#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Build every a64elf command into tools/a64elf/bin/.
# Usage: ./build.sh [--clean]
set -euo pipefail
cd "$(dirname "$0")"

CC="${CC:-cc}"
if ! command -v "$CC" >/dev/null 2>&1; then
  echo "a64elf: no C compiler found (set CC, or install clang/gcc)" >&2
  exit 1
fi

if [ "${1:-}" = "--clean" ]; then
  rm -rf bin
fi
mkdir -p bin

ERRLOG=$(mktemp "${TMPDIR:-/tmp}/a64elf-cc.XXXXXX") || exit 1
trap 'rm -f "$ERRLOG"' EXIT

failed=0
built=0
for source in *.c; do
  name="${source%.c}"
  if [ -x "bin/$name" ] && [ "bin/$name" -nt "$source" ]; then
    continue
  fi
  if "$CC" -O2 -o "bin/$name" "$source" 2>"$ERRLOG"; then
    built=$((built + 1))
    printf '  built %s\n' "$name"
  else
    failed=$((failed + 1))
    printf '  FAILED %s\n' "$name" >&2
    sed 's/^/    /' "$ERRLOG" >&2
  fi
done

total=$(ls -1 *.c | wc -l | tr -d ' ')
echo "a64elf: $built built, $((total - built)) up to date or failed, $failed failed -> bin/"

[ "$failed" -eq 0 ]
