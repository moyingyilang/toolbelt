#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# apk-info — inspect an APK without opening Android Studio.
#
# Works everywhere with unzip/sha256sum. When aapt2 or aapt is available
# (Android SDK build-tools, or on PATH) it also prints package identity,
# versions, the launchable activity and granted permissions.
set -uo pipefail

PROG=apk-info

usage() {
  cat <<'EOF'
apk-info — report an APK's size, hash, native libs and package identity

Usage:
  apk-info <file.apk>

Reads only the zip container and, when available, the Android SDK's aapt2/aapt.
EOF
}

die() { printf '%s: %s\n' "$PROG" "$1" >&2; exit "${2:-1}"; }

[ "$#" -ge 1 ] || { usage >&2; exit 2; }
case "$1" in -h|--help) usage; exit 0 ;; esac

apk=$1
[ -f "$apk" ] || die "no such file: $apk"
command -v unzip >/dev/null 2>&1 || die "unzip is required (Termux: pkg install unzip)"

size=$(wc -c <"$apk" | tr -d ' ')
printf 'file    %s\n' "$apk"
printf 'size    %s bytes\n' "$size"
if command -v sha256sum >/dev/null 2>&1; then
  printf 'sha256  %s\n' "$(sha256sum "$apk" | cut -d' ' -f1)"
fi

listing=$(unzip -l "$apk" 2>/dev/null) || die "not a readable zip: $apk"
entries=$(printf '%s\n' "$listing" | tail -1 | awk '{print $2}')
[ -n "$entries" ] && printf 'entries %s\n' "$entries"

abis=$(printf '%s\n' "$listing" | sed -n 's#.*lib/\([^/]*\)/lib.*#\1#p' | sort -u | tr '\n' ' ')
if [ -n "$abis" ]; then
  printf 'abis    %s\n' "$abis"
else
  printf 'abis    (none — no native libraries)\n'
fi

signatures=$(printf '%s\n' "$listing" | grep -E 'META-INF/.*\.(RSA|DSA|EC)$' | wc -l | tr -d ' ')
if [ "$signatures" -gt 0 ]; then
  printf 'signed  yes (v1 evidence: %s signature file(s))\n' "$signatures"
else
  printf 'signed  no v1 signature (v2+ is inside the zip; use apksigner to verify)\n'
fi

find_aapt() {
  local build_tools
  for candidate in aapt2 aapt; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return 0
    fi
  done
  for sdk in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/android-sdk"; do
    [ -n "$sdk" ] || continue
    for build_tools in "$sdk"/build-tools/*; do
      for candidate in aapt2 aapt; do
        if [ -x "$build_tools/$candidate" ]; then
          printf '%s\n' "$build_tools/$candidate"
          return 0
        fi
      done
    done
  done
  return 1
}

aapt=$(find_aapt) || aapt=""
if [ -n "$aapt" ]; then
  if [ "$(basename "$aapt")" = aapt2 ]; then
    badging=$("$aapt" dump badging "$apk" 2>/dev/null) || badging=""
  else
    badging=$("$aapt" dump badging "$apk" 2>/dev/null) || badging=""
  fi
  if [ -n "$badging" ]; then
    printf '%s\n' "$badging" | grep -E '^(package|sdkVersion|targetSdkVersion|application-label|launchable-activity|native-code)' | sed 's/^/  /'
  fi
else
  printf 'aapt    (not found; set ANDROID_HOME to a build-tools install for package details)\n'
fi
