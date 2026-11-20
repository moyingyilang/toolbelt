#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# android-sdk-install — install the Android command-line SDK into a directory.
#
# Minimal, repeatable: download cmdline-tools, accept licenses, install
# platform-tools, one build-tools version and one platform. Everything stays
# under --dir (default $ANDROID_HOME or ~/android-sdk), no global writes.
set -uo pipefail

PROG=android-sdk-install
CMDLINE_TOOLS_VERSION="11076708"

usage() {
  cat <<'EOF'
android-sdk-install — install the Android command-line SDK into one directory

Usage:
  android-sdk-install [options]

Options:
      --dir DIR            install root (default: $ANDROID_HOME or ~/android-sdk)
      --api N              platform API level (default: 34)
      --build-tools V      build-tools version (default: 34.0.0)
      --ndk V              also install this NDK version
      --no-platform-tools  skip platform-tools (adb, fastboot)
      --no-licenses        do not auto-accept SDK licenses
      --dry-run            print what would happen and exit
  -h, --help               this help

Requirements: java on PATH (or JAVA_HOME), curl or wget, unzip.
On Termux the Google host binaries are Linux x86_64 builds; use a Linux
container (proot-distro) for the SDK's native tools, or `pkg install
android-tools` when only adb/fastboot are needed.
EOF
}

die() { printf '%s: %s\n' "$PROG" "$1" >&2; exit "${2:-1}"; }

sdk_dir="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/android-sdk}}"
api=34
build_tools=34.0.0
ndk=""
platform_tools=1
accept_licenses=1
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dir) [ "$#" -ge 2 ] || die "--dir needs a value" 2; sdk_dir=$2; shift 2 ;;
    --api) [ "$#" -ge 2 ] || die "--api needs a value" 2; api=$2; shift 2 ;;
    --build-tools) [ "$#" -ge 2 ] || die "--build-tools needs a value" 2; build_tools=$2; shift 2 ;;
    --ndk) [ "$#" -ge 2 ] || die "--ndk needs a value" 2; ndk=$2; shift 2 ;;
    --no-platform-tools) platform_tools=0; shift ;;
    --no-licenses) accept_licenses=0; shift ;;
    --dry-run) dry_run=1; shift ;;
    *) die "unknown option $1" 2 ;;
  esac
done

case "$api" in
  ''|*[!0-9]*) die "--api must be a number" 2 ;;
esac

# ---- host checks --------------------------------------------------------

arch=$(uname -m)
case "$arch" in
  x86_64|amd64) arch=x86_64 ;;
  aarch64|arm64) arch=aarch64 ;;
  *) die "unsupported host architecture: $arch" ;;
esac
printf 'host        %s-%s\n' "$(uname -s)" "$arch"
printf 'sdk dir     %s\n' "$sdk_dir"
printf 'java        %s\n' "$(command -v java 2>/dev/null || JAVA_HOME/bin/java 2>/dev/null || printf 'MISSING (install a JDK first)')"

if [ -n "${ANDROID_HOME:-}" ] && [ "$ANDROID_HOME" != "$sdk_dir" ]; then
  printf 'WARNING     ANDROID_HOME=%s differs from --dir=%s\n' "$ANDROID_HOME" "$sdk_dir"
fi
if [ -n "${PREFIX:-}" ] && case "$PREFIX" in *com.termux*) true ;; *) false ;; esac; then
  printf 'WARNING     Termux detected: Google SDK host binaries are Linux x86_64.\n'
  printf '            Use a proot-distro Linux container for build-tools/platform-tools,\n'
  printf '            or `pkg install android-tools` if adb/fastboot are all you need.\n'
fi
url="https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"

packages=( "platforms;android-${api}" "build-tools;${build_tools}" )
[ "$platform_tools" -eq 1 ] && packages=( "platform-tools" "${packages[@]}" )
[ -n "$ndk" ] && packages+=( "ndk;${ndk}" )

if [ "$dry_run" -eq 1 ]; then
  printf '\nwould download %s\n' "$url"
  printf 'would install into %s\n  %s\n' "$sdk_dir" "${packages[*]}"
  printf 'would accept licenses: %s\n' "$([ "$accept_licenses" -eq 1 ] && printf yes || printf no)"
  exit 0
fi

if ! command -v java >/dev/null 2>&1 && { [ -z "${JAVA_HOME:-}" ] || [ ! -x "$JAVA_HOME/bin/java" ]; }; then
  die "java is required; install a JDK (toolbelt run jdk-install, or pkg install openjdk-17)"
fi
if command -v curl >/dev/null 2>&1; then
  downloader="curl -fsSL"
elif command -v wget >/dev/null 2>&1; then
  downloader="wget -qO"
else
  die "curl or wget is required"
fi
command -v unzip >/dev/null 2>&1 || die "unzip is required"

# ---- cmdline-tools ------------------------------------------------------

sdkmanager="$sdk_dir/cmdline-tools/latest/bin/sdkmanager"
if [ ! -x "$sdkmanager" ]; then
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/android-sdk.XXXXXX") || die "cannot create a temp dir"
  trap 'rm -rf "$tmp"' EXIT
  printf 'downloading %s\n' "$url"
  $downloader "$url" > "$tmp/cmdline-tools.zip" || die "download failed"
  unzip -q "$tmp/cmdline-tools.zip" -d "$tmp" || die "unzip failed"
  [ -d "$tmp/cmdline-tools" ] || die "unexpected archive layout"
  mkdir -p "$sdk_dir/cmdline-tools"
  rm -rf "$sdk_dir/cmdline-tools/latest"
  mv "$tmp/cmdline-tools" "$sdk_dir/cmdline-tools/latest"
  rm -rf "$tmp"
  trap - EXIT
else
  printf 'cmdline-tools already present\n'
fi

export ANDROID_HOME="$sdk_dir"
export ANDROID_SDK_ROOT="$sdk_dir"

if [ "$accept_licenses" -eq 1 ]; then
  if command -v yes >/dev/null 2>&1; then
    yes | "$sdkmanager" --sdk_root="$sdk_dir" --licenses >/dev/null 2>&1 || true
  else
    printf 'y\n%.0s' 1 2 3 4 5 6 7 8 9 10 | "$sdkmanager" --sdk_root="$sdk_dir" --licenses >/dev/null 2>&1 || true
  fi
  printf 'licenses accepted\n'
fi

printf 'installing: %s\n' "${packages[*]}"
"$sdkmanager" --sdk_root="$sdk_dir" "${packages[@]}" || die "sdkmanager failed" 1

printf '\ninstalled under %s\n' "$sdk_dir"
printf 'export ANDROID_HOME="%s"\n' "$sdk_dir"
printf 'export ANDROID_SDK_ROOT="%s"\n' "$sdk_dir"
printf 'export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"\n'
