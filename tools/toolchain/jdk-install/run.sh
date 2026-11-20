#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# jdk-install — install a Temurin JDK tarball into a user directory.
#
# Queries the Adoptium API for the latest build of one major version, checks
# the published SHA-256, extracts it under --dir, and prints the exports to add
# to your shell. No apt, no sudo, no global writes.
set -uo pipefail

PROG=jdk-install

usage() {
  cat <<'EOF'
jdk-install — install a Temurin JDK into a user directory (Linux)

Usage:
  jdk-install [options]

Options:
      --version N   JDK major version (default: 21)
      --dir DIR     install root (default: ~/.local/opt)
      --dry-run     print the release URL and exit
  -h, --help        this help

Uses the Adoptium API: https://api.adoptium.net/
Requires curl or wget, tar, and sha256sum.
On Termux the Temurin Linux builds are glibc-based and will not run; use
`pkg install openjdk-17` there instead.
EOF
}

die() { printf '%s: %s\n' "$PROG" "$1" >&2; exit "${2:-1}"; }

version=21
dir="$HOME/.local/opt"
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --version) [ "$#" -ge 2 ] || die "--version needs a value" 2; version=$2; shift 2 ;;
    --dir) [ "$#" -ge 2 ] || die "--dir needs a value" 2; dir=$2; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    *) die "unknown option $1" 2 ;;
  esac
done
case "$version" in
  ''|*[!0-9]*) die "--version must be a number" 2 ;;
esac

arch=$(uname -m)
case "$arch" in
  x86_64|amd64) adoptium_arch=x64 ;;
  aarch64|arm64) adoptium_arch=aarch64 ;;
  *) die "unsupported host architecture: $arch" ;;
esac

if [ -n "${PREFIX:-}" ] && case "$PREFIX" in *com.termux*) true ;; *) false ;; esac; then
  die "Temurin Linux builds are glibc binaries and will not run on Termux; use: pkg install openjdk-17" 2
fi

if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -qO- "$1"; }
else
  die "curl or wget is required"
fi
command -v tar >/dev/null 2>&1 || die "tar is required"

json_url="https://api.adoptium.net/v3/assets/latest/${version}/hotspot?architecture=${adoptium_arch}&image_type=jdk&os=linux&vendor=eclipse"
printf 'querying %s\n' "$json_url"

json=$(fetch "$json_url") || die "Adoptium API request failed"
link=$(printf '%s' "$json" | grep -o '"link"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"link"[[:space:]]*:[[:space:]]*"//; s/"$//')
checksum=$(printf '%s' "$json" | grep -o '"checksum"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"checksum"[[:space:]]*:[[:space:]]*"//; s/"$//')

[ -n "$link" ] || die "could not find a download link for JDK ${version} linux-${adoptium_arch}"
printf 'release    %s\n' "$link"
[ -n "$checksum" ] && printf 'sha256     %s\n' "$checksum"

if [ "$dry_run" -eq 1 ]; then
  printf 'would install under %s\n' "$dir"
  exit 0
fi

mkdir -p "$dir" || die "cannot create $dir"
tmp=$(mktemp "${TMPDIR:-/tmp}/jdk-install.XXXXXX") || die "cannot create a temp file"
trap 'rm -f "$tmp"' EXIT
printf 'downloading...\n'
if command -v curl >/dev/null 2>&1; then
  curl -fsSL -o "$tmp" "$link" || die "download failed"
else
  wget -qO "$tmp" "$link" || die "download failed"
fi

if [ -n "$checksum" ]; then
  actual=$(sha256sum "$tmp" | cut -d' ' -f1)
  if [ "$actual" != "$checksum" ]; then
    die "checksum mismatch: expected $checksum, got $actual"
  fi
  printf 'checksum   ok\n'
fi

printf 'extracting into %s...\n' "$dir"
tar -xzf "$tmp" -C "$dir" || die "extraction failed"
rm -f "$tmp"
trap - EXIT

java_home=$(find "$dir" -maxdepth 1 -type d -name "jdk-${version}*" | sort | tail -1)
[ -n "$java_home" ] || die "extracted JDK directory not found under $dir"

printf '\ninstalled %s\n' "$java_home"
printf 'export JAVA_HOME="%s"\n' "$java_home"
printf 'export PATH="$JAVA_HOME/bin:$PATH"\n'
