#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Entry point used by `toolbelt run ab-header`; builds on first use.
set -euo pipefail
cd "$(dirname "$0")"
if [ ! -x "bin/ab-header" ] || [ "ab_header.c" -nt "bin/ab-header" ] || [ "build.sh" -nt "bin/ab-header" ]; then
  ./build.sh
fi
exec "bin/ab-header" "$@"
