#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Entry point used by `toolbelt run lz4-block`; builds on first use.
set -euo pipefail
cd "$(dirname "$0")"
if [ ! -x "bin/lz4-block" ] || [ "lz4_block.c" -nt "bin/lz4-block" ] || [ "build.sh" -nt "bin/lz4-block" ]; then
  ./build.sh
fi
exec "bin/lz4-block" "$@"
