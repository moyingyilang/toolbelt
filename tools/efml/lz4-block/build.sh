#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Build lz4-block into bin/lz4-block (incremental).
set -euo pipefail
cd "$(dirname "$0")"
CC="${CC:-cc}"
command -v "$CC" >/dev/null 2>&1 || {
  echo "lz4-block: no C compiler found (set CC, or install clang/gcc)" >&2
  exit 1
}
mkdir -p bin
if [ ! -x "bin/lz4-block" ] || [ "lz4_block.c" -nt "bin/lz4-block" ]; then
  "$CC" -O2 -std=c11 -Wall -Wextra -o "bin/lz4-block" "lz4_block.c"
  echo "lz4-block: built bin/lz4-block"
fi
