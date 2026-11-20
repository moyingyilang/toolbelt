#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# android-build — build an Android (Gradle) project from the terminal.
#
# This is the generalized form of a per-project builder: the project path,
# variant, clean and install steps used to be hard-coded in shell history.
# It works in Termux directly and in any Linux shell.
set -uo pipefail

PROG=android-build

usage() {
  cat <<'EOF'
android-build — build an Android Gradle project, then report or install the APK

Usage:
  android-build [project] [options] [-- gradle args...]

    [project]            project directory containing gradlew (default: .)

Options:
  -v, --variant NAME   debug or release (default: release)
      --clean          run the clean task before assembling
      --install        install every produced APK with adb install -r
      --daemon         keep the Gradle daemon (default: --no-daemon)
      --env            print the detected toolchain and exit
  -h, --help           this help

Examples:
  android-build ~/jmc/JMNeXt
  android-build --variant debug --clean
  android-build --install -- --stacktrace
EOF
}

die() { printf '%s: %s\n' "$PROG" "$1" >&2; exit "${2:-1}"; }

project="."
variant="release"
clean=0
install_apk=0
use_daemon=0
env_only=0
gradle_args=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -v|--variant)
      [ "$#" -ge 2 ] || die "--variant needs a value" 2
      variant=$2
      shift 2
      ;;
    --clean) clean=1; shift ;;
    --install) install_apk=1; shift ;;
    --daemon) use_daemon=1; shift ;;
    --env) env_only=1; shift ;;
    --)
      shift
      gradle_args=("$@")
      break
      ;;
    -*) die "unknown option $1" 2 ;;
    *) project=$1; shift ;;
  esac
done

case "$variant" in
  debug|release) ;;
  *) die "variant must be debug or release" 2 ;;
esac

[ -d "$project" ] || die "no such project directory: $project"
cd "$project" || die "cannot enter $project"
[ -f gradlew ] || die "no gradlew here; point this at a Gradle project"
chmod +x gradlew 2>/dev/null || true

# ---- toolchain detection ------------------------------------------------

java_bin=""
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  java_bin="$JAVA_HOME/bin/java"
else
  java_bin=$(command -v java 2>/dev/null) || java_bin=""
fi
if [ -z "$java_bin" ]; then
  die "java not found; install a JDK (Termux: pkg install openjdk-17)"
fi
if [ -z "${JAVA_HOME:-}" ]; then
  export JAVA_HOME
  JAVA_HOME=$(cd "$(dirname "$java_bin")/.." && pwd)
fi
java_version=$("$java_bin" -version 2>&1 | head -1)

sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [ -z "$sdk" ] && [ -f local.properties ]; then
  sdk=$(sed -n 's/^sdk\.dir=//p' local.properties | head -1)
fi
if [ -z "$sdk" ]; then
  for candidate in "${ANDROID_SDK_ROOT:-}" "$HOME/android-sdk" "${PREFIX:-/usr}/opt/android-sdk"; do
    if [ -n "$candidate" ] && [ -d "$candidate" ]; then
      sdk=$candidate
      break
    fi
  done
fi

printf 'project  : %s\n' "$(pwd)"
printf 'variant  : %s\n' "$variant"
printf 'java     : %s\n' "$java_version"
if [ -n "$sdk" ]; then printf 'android  : %s\n' "$sdk"; else printf 'android  : (not detected; Gradle may still find the SDK)\n'; fi
[ "$env_only" -eq 1 ] && exit 0

# ---- build --------------------------------------------------------------

if [ "$use_daemon" -eq 1 ]; then
  gradle_flags=(--console=plain)
else
  gradle_flags=(--console=plain --no-daemon)
fi
task="assemble${variant^}"
if [ "$clean" -eq 1 ]; then
  gradle_flags+=(clean)
fi
gradle_flags+=("$task")
if [ "${#gradle_args[@]}" -gt 0 ]; then
  gradle_flags+=("${gradle_args[@]}")
fi

printf '+ ./gradlew %s\n' "${gradle_flags[*]}"
marker=$(mktemp "${TMPDIR:-/tmp}/android-build.XXXXXX") || die "cannot create a temp marker"
trap 'rm -f "$marker"' EXIT
if ! ./gradlew "${gradle_flags[@]}"; then
  die "gradle failed"
fi

# ---- report produced APKs ----------------------------------------------

apks=()
while IFS= read -r apk; do
  apks+=("$apk")
done < <(find . -path '*/build/outputs/apk/*' -name '*.apk' -newer "$marker" 2>/dev/null | sort)

if [ "${#apks[@]}" -eq 0 ]; then
  printf '%s: no APK produced under */build/outputs/apk/\n' "$PROG" >&2
  exit 1
fi

for apk in "${apks[@]}"; do
  size=$(wc -c <"$apk" | tr -d ' ')
  if command -v sha256sum >/dev/null 2>&1; then
    digest=$(sha256sum "$apk" | cut -d' ' -f1)
    printf 'APK %s\n    %s bytes  sha256 %s\n' "$apk" "$size" "$digest"
  else
    printf 'APK %s\n    %s bytes\n' "$apk" "$size"
  fi
done

if [ "$install_apk" -eq 1 ]; then
  command -v adb >/dev/null 2>&1 || die "adb not found; install android-tools"
  for apk in "${apks[@]}"; do
    printf 'adb install -r %s\n' "$apk"
    adb install -r "$apk" || die "adb install failed for $apk"
  done
fi
