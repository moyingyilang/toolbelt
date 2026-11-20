# android-sdk-install

Install the Android command-line SDK into one directory: download
`cmdline-tools`, accept the licenses, install `platform-tools`, one
`build-tools` version and one platform. Everything stays under `--dir`; there
are no global writes and no sudo.

```bash
tools/toolchain/android-sdk-install/run.sh --dry-run
tools/toolchain/android-sdk-install/run.sh --dir ~/android-sdk --api 34 --build-tools 34.0.0
toolbelt run android-sdk-install -- --dry-run
```

| option | meaning |
| --- | --- |
| `--dir DIR` | install root (default `$ANDROID_HOME` or `~/android-sdk`) |
| `--api N` | platform API level (default 34) |
| `--build-tools V` | build-tools version (default 34.0.0) |
| `--ndk V` | also install an NDK |
| `--no-platform-tools` | skip `platform-tools` |
| `--no-licenses` | do not auto-accept licenses |
| `--dry-run` | print the plan and exit |

Requirements: a JDK (`toolbelt run jdk-install`), `curl`/`wget`, `unzip`.

**Termux note:** Google's `build-tools`/`platform-tools` binaries are Linux
x86_64 host builds and do not run on Android/aarch64. Use a `proot-distro`
Linux container for the full SDK, or `pkg install android-tools` when you only
need `adb`/`fastboot`.

Afterwards, add the printed exports to your shell:

```bash
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```
