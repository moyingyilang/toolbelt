#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# toolchain-doctor — check a build toolchain (JDK, Gradle, Android SDK/NDK,
# C/C++, Rust, Go, Node, Python) and print install hints for the missing parts.
set -uo pipefail

PROG=toolchain-doctor
MISSING=0
WARN=0

if [ -n "${PREFIX:-}" ] && case "$PREFIX" in *com.termux*) true ;; *) false ;; esac; then
  FAMILY=termux
elif command -v apt-get >/dev/null 2>&1; then
  FAMILY=debian
elif command -v dnf >/dev/null 2>&1; then
  FAMILY=fedora
else
  FAMILY=unknown
fi

hint() {
  case "$FAMILY:$1" in
    termux:java) printf 'pkg install openjdk-17' ;;
    termux:gradle) printf 'download from gradle.org, or use a project gradlew' ;;
    termux:android) printf 'use a proot-distro Linux container, or pkg install android-tools' ;;
    termux:cc) printf 'pkg install clang' ;;
    termux:make) printf 'pkg install make' ;;
    termux:cmake) printf 'pkg install cmake' ;;
    termux:zlib) printf 'pkg install zlib' ;;
    termux:rust) printf 'pkg install rust' ;;
    termux:go) printf 'pkg install golang' ;;
    termux:node) printf 'pkg install nodejs' ;;
    termux:python) printf 'pkg install python' ;;
    termux:git) printf 'pkg install git' ;;
    debian:java) printf 'apt install default-jdk' ;;
    debian:gradle) printf 'apt install gradle, or use a project gradlew' ;;
    debian:android) printf 'install Android cmdline-tools (toolbelt run android-sdk-install)' ;;
    debian:cc) printf 'apt install build-essential clang' ;;
    debian:make) printf 'apt install make' ;;
    debian:cmake) printf 'apt install cmake' ;;
    debian:zlib) printf 'apt install zlib1g-dev' ;;
    debian:rust) printf 'curl https://sh.rustup.rs -sSf | sh' ;;
    debian:go) printf 'apt install golang-go' ;;
    debian:node) printf 'apt install nodejs npm' ;;
    debian:python) printf 'apt install python3' ;;
    debian:git) printf 'apt install git' ;;
    *) printf 'install %s' "$1" ;;
  esac
}

have() { command -v "$1" >/dev/null 2>&1; }

ok() { printf '  ✓ %-12s %s\n' "$1" "$2"; }
warn() { WARN=$((WARN + 1)); printf '  ! %-12s %s\n' "$1" "$2"; }
bad() { MISSING=$((MISSING + 1)); printf '  ✗ %-12s %s\n' "$1" "$2"; }

require() {
  local name="$1" command_name="$2" version_command="$3" kind="$4"
  if have "$command_name"; then
    local version
    version=$(eval "$version_command" 2>/dev/null | head -1)
    ok "$name" "${version:-present}"
  elif [ "$kind" = warn ]; then
    warn "$name" "missing — $(hint "$name")"
  else
    bad "$name" "missing — $(hint "$name")"
  fi
}

printf '%s — build toolchain check\n\n' "$PROG"
printf 'host        %s %s\n' "$(uname -s)" "$(uname -m)"
printf 'family      %s\n' "$FAMILY"
if have pkg-config; then ok "pkg-config" "$(pkg-config --version)"; else warn "pkg-config" "missing"; fi
if have git; then ok "git" "$(git --version)"; else warn "git" "missing — $(hint git)"; fi

printf '\nJVM\n'
require java java 'java -version' critical
require javac javac 'javac -version' warn
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  ok "JAVA_HOME" "$JAVA_HOME"
else
  warn "JAVA_HOME" "not set — export JAVA_HOME=$(have javac && dirname "$(dirname "$(command -v javac)")" || printf '<jdk>')"
fi
require gradle gradle 'gradle --version' warn

printf '\nAndroid SDK\n'
if [ -n "${ANDROID_HOME:-}" ]; then
  ok "ANDROID_HOME" "$ANDROID_HOME"
elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  ok "ANDROID_SDK_ROOT" "$ANDROID_SDK_ROOT"
else
  warn "SDK env" "ANDROID_HOME/ANDROID_SDK_ROOT not set — $(hint android)"
fi
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [ -n "$sdk" ]; then
  build_tools=$(find "$sdk/build-tools" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
  if [ -n "$build_tools" ]; then ok "build-tools" "$(basename "$build_tools")"; else warn "build-tools" "not installed — $(hint android)"; fi
  platform=$(find "$sdk/platforms" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
  if [ -n "$platform" ]; then ok "platforms" "$(basename "$platform")"; else warn "platforms" "not installed — $(hint android)"; fi
  if [ -x "$sdk/cmdline-tools/latest/bin/sdkmanager" ]; then ok "sdkmanager" "$sdk/cmdline-tools/latest/bin/sdkmanager"; else warn "sdkmanager" "not installed — toolbelt run android-sdk-install"; fi
  if [ -n "${ANDROID_NDK_HOME:-}" ]; then ok "NDK" "$ANDROID_NDK_HOME"; elif [ -d "$sdk/ndk" ]; then ok "NDK" "$(find "$sdk/ndk" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)"; else warn "NDK" "not installed (only needed for native code)"; fi
fi
if have adb; then ok "adb" "$(adb version 2>/dev/null | head -1)"; else warn "adb" "missing — $(hint android)"; fi

printf '\nC / C++\n'
require cc cc 'cc --version' critical
require make make 'make --version' critical
require cmake cmake 'cmake --version' warn
if have pkg-config && pkg-config --exists zlib 2>/dev/null; then ok "zlib" "$(pkg-config --modversion zlib)"; else warn "zlib" "missing — $(hint zlib)"; fi

printf '\nOther toolchains\n'
require rustc rustc 'rustc --version' warn
require cargo cargo 'cargo --version' warn
require go go 'go version' warn
require node node 'node --version' warn
require python3 python3 'python3 --version' warn

printf '\n%s: %d missing, %d warnings\n' "$PROG" "$MISSING" "$WARN"
printf 'critical tools: java, cc, make\n'
[ "$MISSING" -eq 0 ]
