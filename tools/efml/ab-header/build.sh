#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Build ab-header into bin/ab-header (incremental).
set -euo pipefail
cd "$(dirname "$0")"
CC="${CC:-cc}"
command -v "$CC" >/dev/null 2>&1 || {
  echo "ab-header: no C compiler found (set CC, or install clang/gcc)" >&2
  exit 1
}
mkdir -p bin
if [ ! -x "bin/ab-header" ] || [ "ab_header.c" -nt "bin/ab-header" ]; then
  "$CC" -O2 -std=c11 -Wall -Wextra -o "bin/ab-header" "ab_header.c"
  echo "ab-header: built bin/ab-header"
fi
