#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Entry point used by `toolbelt run a64elf`.
#
#   ./run.sh                      build every command, then list them
#   ./run.sh build                rebuild incrementally
#   ./run.sh <tool> [args...]     build if needed, then run bin/<tool>
#   ./run.sh list                 list available commands
set -euo pipefail
cd "$(dirname "$0")"

need_build() {
  if [ ! -d bin ] || [ -z "$(ls -A bin 2>/dev/null)" ]; then
    return 0
  fi
  for source in *.c; do
    name="${source%.c}"
    if [ ! -x "bin/$name" ] || [ "$source" -nt "bin/$name" ]; then
      return 0
    fi
  done
  return 1
}

if need_build; then
  ./build.sh
fi

if [ "$#" -eq 0 ] || [ "${1:-}" = build ]; then
  ./build.sh
  echo
  echo "commands in tools/a64elf/bin:"
  ls -1 bin | sed 's/^/  /'
  exit 0
fi

if [ "${1:-}" = list ]; then
  ls -1 bin | sed 's/^/  /'
  exit 0
fi

tool="$1"
shift
if [ ! -x "bin/$tool" ]; then
  echo "a64elf: unknown tool \"$tool\"; available:" >&2
  ls -1 bin 2>/dev/null | sed 's/^/  /' >&2 || true
  exit 2
fi
exec "bin/$tool" "$@"
