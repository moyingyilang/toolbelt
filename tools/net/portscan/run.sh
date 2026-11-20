#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# portscan — parallel TCP connect scan built on bash's /dev/tcp.
#
# This is the generalized form of a one-off local script: the target IP, port
# range and concurrency used to be hard-coded. Now every piece is an argument.
set -uo pipefail

PROG=${0##*/}

usage() {
  cat <<'EOF'
portscan — parallel TCP connect scan over bash /dev/tcp

Usage:
  portscan <host> <ports> [options]

    <host>          hostname or IPv4 address to probe
    <ports>         "22,80,443", "1-1024", or a mix: "22,8000-8100,443"

Options:
  -j, --jobs N       concurrent probes (default 64)
  -t, --timeout SEC  per-probe connect timeout via timeout(1) (0 = none)
  -q, --quiet        suppress the summary on stderr
  -h, --help         this help

Output: one "OPEN <port>" line per open port on stdout; a summary on stderr.

Examples:
  portscan 192.168.1.1 1-1024
  portscan example.com 22,80,443 --jobs 32
  portscan 127.0.0.1 8000-8100 -q
EOF
}

host=""
ports=""
jobs=64
timeout=0
quiet=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -j|--jobs)
      [ "$#" -ge 2 ] || { echo "$PROG: --jobs needs a value" >&2; exit 2; }
      jobs=$2; shift 2 ;;
    -t|--timeout)
      [ "$#" -ge 2 ] || { echo "$PROG: --timeout needs a value" >&2; exit 2; }
      timeout=$2; shift 2 ;;
    -q|--quiet) quiet=1; shift ;;
    --) shift; break ;;
    -*)
      echo "$PROG: unknown option $1" >&2
      usage >&2
      exit 2 ;;
    *)
      if [ -z "$host" ]; then host=$1
      elif [ -z "$ports" ]; then ports=$1
      else echo "$PROG: unexpected extra argument $1" >&2; exit 2
      fi
      shift ;;
  esac
done
[ "$#" -gt 0 ] && { echo "$PROG: unexpected extra arguments: $*" >&2; exit 2; }

if [ -z "$host" ] || [ -z "$ports" ]; then
  usage >&2
  exit 2
fi
if ! [[ "$jobs" =~ ^[0-9]+$ ]] || [ "$jobs" -lt 1 ] || [ "$jobs" -gt 1024 ]; then
  echo "$PROG: --jobs must be an integer between 1 and 1024" >&2
  exit 2
fi
if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
  echo "$PROG: --timeout must be a non-negative integer" >&2
  exit 2
fi
command -v bash >/dev/null 2>&1 || { echo "$PROG: bash is required for /dev/tcp" >&2; exit 1; }
[ "$timeout" -gt 0 ] && ! command -v timeout >/dev/null 2>&1 && {
  echo "$PROG: --timeout needs the timeout(1) command" >&2
  exit 1
}

expand_ports() {
  local spec=$1 part start end
  local -a parts
  IFS=',' read -r -a parts <<<"$spec"
  for part in "${parts[@]}"; do
    part=${part//[[:space:]]/}
    [ -z "$part" ] && continue
    if [[ $part =~ ^([0-9]+)-([0-9]+)$ ]]; then
      start=${BASH_REMATCH[1]}
      end=${BASH_REMATCH[2]}
      if [ "$start" -lt 1 ] || [ "$start" -gt 65535 ] || [ "$end" -lt 1 ] || [ "$end" -gt 65535 ] || [ "$start" -gt "$end" ]; then
        echo "$PROG: invalid port range $part" >&2
        exit 2
      fi
      seq "$start" "$end"
    elif [[ $part =~ ^[0-9]+$ ]]; then
      if [ "$part" -lt 1 ] || [ "$part" -gt 65535 ]; then
        echo "$PROG: invalid port $part" >&2
        exit 2
      fi
      echo "$part"
    else
      echo "$PROG: invalid port spec $part" >&2
      exit 2
    fi
  done
}

mapfile -t PORTLIST < <(expand_ports "$ports")
TOTAL=${#PORTLIST[@]}
if [ "$TOTAL" -eq 0 ]; then
  echo "$PROG: no ports to scan" >&2
  exit 2
fi

probe() {
  local port=$1
  if [ "$timeout" -gt 0 ]; then
    timeout "$timeout" bash -c 'exec 3<>"/dev/tcp/$0/$1"' "$host" "$port" 2>/dev/null
  else
    (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null
  fi
}

RESULTS=$(mktemp "${TMPDIR:-/tmp}/portscan.XXXXXX") || exit 1
trap 'rm -f "$RESULTS"' EXIT

started=$(date +%s)
pids=()
for port in "${PORTLIST[@]}"; do
  (probe "$port" && printf '%s\n' "$port" >>"$RESULTS") &
  pids+=("$!")
  if [ "${#pids[@]}" -ge "$jobs" ]; then
    wait "${pids[@]}" 2>/dev/null
    pids=()
  fi
done
[ "${#pids[@]}" -gt 0 ] && wait "${pids[@]}" 2>/dev/null

count=0
if [ -s "$RESULTS" ]; then
  while IFS= read -r port; do
    printf 'OPEN %s\n' "$port"
    count=$((count + 1))
  done < <(sort -n "$RESULTS")
fi

if [ "$quiet" -eq 0 ]; then
  elapsed=$(( $(date +%s) - started ))
  printf '%s: %d/%d open on %s in %ds\n' "$PROG" "$count" "$TOTAL" "$host" "$elapsed" >&2
fi
