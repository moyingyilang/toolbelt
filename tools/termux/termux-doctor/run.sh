#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# termux-doctor — check the Android/Termux environment for the traps that make
# Node, Python, npm and other toolchains fail on-device.
#
# These checks are the generalized form of a local debugging checklist:
# hard links denied by sepolicy, tiny default Node heaps, missing wheels and
# registries, UTF-8 assumptions and storage permissions.
set -uo pipefail

PROG=termux-doctor
OK=0
WARN=0
BAD=0

ok() { OK=$((OK + 1)); printf '  ✓ %s\n' "$1"; }
warn() { WARN=$((WARN + 1)); printf '  ! %s\n' "$1"; }
bad() { BAD=$((BAD + 1)); printf '  ✗ %s\n' "$1"; }

printf '%s — environment check\n\n' "$PROG"

# ---- shell and locale ---------------------------------------------------

ok "bash ${BASH_VERSION}"

case "${LANG:-}" in
  *UTF-8*|*utf8*|*UTF8*) ok "locale: ${LANG}" ;;
  *) warn "locale is not UTF-8 (LANG=${LANG:-unset}); CJK widths and Python may misbehave" ;;
esac

if [ -n "${PREFIX:-}" ] && case "$PREFIX" in *com.termux*) true ;; *) false ;; esac; then
  ok "Termux prefix: $PREFIX"
else
  warn "not a Termux prefix (PREFIX=${PREFIX:-unset}); fine on desktop Linux"
fi

# ---- filesystem ---------------------------------------------------------

tmp=$(mktemp -d "${TMPDIR:-/tmp}/${PROG}.XXXXXX") || { bad "cannot create a temp dir"; tmp=""; }
if [ -n "$tmp" ]; then
  if [ -w "$tmp" ]; then ok "temp dir writable: $tmp"; else bad "temp dir is not writable: $tmp"; fi
  touch "$tmp/a" 2>/dev/null
  if ln "$tmp/a" "$tmp/b" 2>/dev/null; then
    ok "hard links work (link(2) is permitted)"
  else
    warn "hard links denied (Android sepolicy); tools using link(2) need a rename fallback"
  fi
  rm -rf "$tmp"
fi

home_free=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
if [ -n "$home_free" ]; then
  home_free_mb=$((home_free / 1024))
  if [ "$home_free_mb" -lt 512 ]; then warn "only ${home_free_mb} MiB free in \$HOME"; else ok "\$HOME free space: ${home_free_mb} MiB"; fi
else
  warn "cannot read free space for \$HOME"
fi

if [ -d /sdcard ] && [ -r /sdcard ]; then
  ok "shared storage readable (/sdcard)"
else
  warn "shared storage not readable; run termux-setup-storage if you need it"
fi

# ---- networking ---------------------------------------------------------

if (exec 3<>/dev/tcp/127.0.0.1/1) 2>/dev/null; then
  ok "bash /dev/tcp works"
else
  probe=$( (exec 3<>/dev/tcp/127.0.0.1/1) 2>&1 )
  case "$probe" in
    *"No such file"*) bad "bash /dev/tcp is not supported by this bash build" ;;
    *) ok "bash /dev/tcp works" ;;
  esac
fi

if command -v node >/dev/null 2>&1; then
  node_version=$(node --version 2>/dev/null)
  ok "node: $node_version"
  heap=$(node -e 'console.log(process.execArgv.filter(a => a.includes("max-old-space")).join(" ") || "default")' 2>/dev/null || printf 'default')
  case "$heap" in
    default) warn "node runs with the default heap; for big builds try --max-old-space-size=4096" ;;
    *) ok "node heap: $heap" ;;
  esac
else
  warn "node not installed"
fi

if command -v python3 >/dev/null 2>&1; then
  python_version=$(python3 --version 2>&1)
  ok "$python_version"
  if python3 -c 'import sysconfig; print(sysconfig.get_platform())' 2>/dev/null | grep -q android; then
    warn "Python reports an android platform; many PyPI projects ship no android wheels"
  fi
else
  warn "python3 not installed"
fi

# ---- Android toolchain --------------------------------------------------

if command -v adb >/dev/null 2>&1; then
  ok "adb: $(command -v adb)"
else
  warn "adb not installed (pkg install android-tools)"
fi

if [ -n "${ANDROID_HOME:-}" ] || [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  ok "Android SDK: ${ANDROID_HOME:-${ANDROID_SDK_ROOT}}"
else
  warn "ANDROID_HOME/ANDROID_SDK_ROOT is not set; Gradle builds may not find the SDK"
fi

for jdk in java javac; do
  if command -v "$jdk" >/dev/null 2>&1; then
    ok "$jdk: $("$jdk" -version 2>&1 | head -1)"
  else
    warn "$jdk not installed"
  fi
done

# ---- summary ------------------------------------------------------------

printf '\n%s checks: %d ok, %d warnings, %d failed\n' "$PROG" "$OK" "$WARN" "$BAD"
[ "$BAD" -eq 0 ]
