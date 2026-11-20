#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Toolbelt test suite: catalog validation, CLI behaviour and bundled tools.
# No test framework — just bash. Run from anywhere: bash tests/run.sh

set -u
ROOT=$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TB="$ROOT/toolbelt"
CATALOG="$ROOT/catalog/toolkits.ini"

PASS=0
FAIL=0

ok() {
  PASS=$(( PASS + 1 ))
  printf 'ok   %s\n' "$1"
}

fail() {
  FAIL=$(( FAIL + 1 ))
  printf 'FAIL %s\n' "$1"
  [ "$#" -gt 1 ] && printf '     %s\n' "$2"
}

check_contains() {
  local description="$1" needle="$2" haystack="$3"
  case "$haystack" in
    *"$needle"*) ok "$description" ;;
    *) fail "$description" "expected to contain: $needle" ;;
  esac
}

check_exit() {
  local description="$1" expected="$2" actual="$3"
  if [ "$actual" -eq "$expected" ]; then ok "$description"; else fail "$description" "exit $actual, expected $expected"; fi
}

# ---- catalog and CLI ------------------------------------------------------

OUT=$("$TB" --version)
check_contains "version" "toolbelt 0.4.0" "$OUT"

COUNT=$(cd "$ROOT" && "$TB" list --json | grep -c '"id":')
if [ "$COUNT" -eq 5 ]; then ok "list --json returns 5 tools"; else fail "list --json returns 5 tools" "got $COUNT"; fi

OUT=$(cd "$ROOT" && "$TB" show portscan)
check_contains "show prints the usage line" "usage" "$OUT"
check_contains "show prints the entry" "tools/net/portscan/run.sh" "$OUT"

OUT=$(cd "$ROOT" && "$TB" search android)
check_contains "search finds the android tools" "android-build" "$OUT"

OUT=$(cd "$ROOT" && "$TB" stats --json)
check_contains "stats reports the total" '"total": 5' "$OUT"

CATS=$(cd "$ROOT" && "$TB" categories --json | grep -c '"count":')
if [ "$CATS" -eq 4 ]; then ok "categories --json lists 4 categories"; else fail "categories --json lists 4 categories" "got $CATS"; fi

OUT=$(cd "$ROOT" && "$TB" doctor --json)
check_contains "doctor passes" '"ok": true' "$OUT"

OUT=$(cd "$ROOT" && TOOLBELT_LAYOUT=compact "$TB" doctor)
check_contains "layout override is honoured" "layout: compact" "$OUT"

# ---- TUI falls back off a TTY --------------------------------------------

ERR=$(cd "$ROOT" && "$TB" tui 2>&1 >/dev/null)
check_contains "tui warns when not a TTY" "no TTY" "$ERR"
OUT=$(cd "$ROOT" && "$TB" tui 2>/dev/null)
check_contains "tui falls back to the list" "toolkits" "$OUT"

# ---- error paths ----------------------------------------------------------

"$TB" frobnicate >/dev/null 2>&1
check_exit "unknown command exits 2" 2 $?

"$TB" show no-such-toolkit >/dev/null 2>&1
check_exit "unknown toolkit exits 2" 2 $?

"$TB" search >/dev/null 2>&1
check_exit "search without a query exits 2" 2 $?

BAD_CATALOG=$(mktemp "${TMPDIR:-/tmp}/toolbelt-bad.XXXXXX")
sed 's/^status=active$/status=zombie/' "$CATALOG" > "$BAD_CATALOG"
TOOLBELT_CATALOG="$BAD_CATALOG" "$TB" list >/dev/null 2>&1
STATUS=$?
rm -f "$BAD_CATALOG"
check_exit "invalid catalog status is rejected" 1 "$STATUS"

# ---- bundled tool: portscan ---------------------------------------------

if command -v python3 >/dev/null 2>&1; then
  PORT_FILE=$(mktemp "${TMPDIR:-/tmp}/toolbelt-port.XXXXXX")
  python3 - "$PORT_FILE" <<'PY' &
import socket, sys
server = socket.socket()
server.bind(("127.0.0.1", 0))
server.listen(4)
open(sys.argv[1], "w").write(str(server.getsockname()[1]))
while True:
    connection, _ = server.accept()
    connection.close()
PY
  SERVER_PID=$!
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -s "$PORT_FILE" ] && break
    sleep 0.1
  done
  PORT=$(cat "$PORT_FILE")
  OUT=$("$TB" run portscan -- 127.0.0.1 "$PORT" -q 2>/dev/null)
  kill "$SERVER_PID" 2>/dev/null
  rm -f "$PORT_FILE"
  check_contains "portscan finds a live local port" "OPEN $PORT" "$OUT"
else
  printf 'skip portscan test (python3 is unavailable)\n'
fi

# ---- bundled tool: a64elf ------------------------------------------------

if command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1; then
  OUT=$("$TB" run a64elf -- list 2>/dev/null)
  check_contains "a64elf builds and lists commands" "findptr" "$OUT"
  check_contains "a64elf lists funcmap" "funcmap" "$OUT"
else
  printf 'skip a64elf test (no C compiler)\n'
fi

# ---- bundled tool: android-build ----------------------------------------

OUT=$("$TB" run android-build -- --help 2>/dev/null)
check_contains "android-build shows help" "build an Android Gradle project" "$OUT"

EMPTY_DIR=$(mktemp -d "${TMPDIR:-/tmp}/toolbelt-empty.XXXXXX")
"$TB" run android-build -- "$EMPTY_DIR" >/dev/null 2>&1
check_exit "android-build rejects a directory without gradlew" 1 $?
rm -rf "$EMPTY_DIR"

# ---- bundled tool: apk-info ---------------------------------------------

if command -v python3 >/dev/null 2>&1; then
  FAKE_APK=$(mktemp "${TMPDIR:-/tmp}/toolbelt-apk.XXXXXX.zip")
  python3 - "$FAKE_APK" <<'PY'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1], "w") as archive:
    archive.writestr("AndroidManifest.xml", b"\x00")
    archive.writestr("lib/arm64-v8a/libx.so", b"\x7fELF")
PY
  OUT=$("$TB" run apk-info -- "$FAKE_APK" 2>/dev/null)
  check_contains "apk-info reports sha256" "sha256" "$OUT"
  check_contains "apk-info lists the ABI" "arm64-v8a" "$OUT"
  rm -f "$FAKE_APK"
else
  printf 'skip apk-info test (python3 is unavailable)\n'
fi

# ---- bundled tool: termux-doctor ----------------------------------------

OUT=$("$TB" run termux-doctor 2>/dev/null)
check_contains "termux-doctor runs its checks" "environment check" "$OUT"

# ---- summary -------------------------------------------------------------

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
