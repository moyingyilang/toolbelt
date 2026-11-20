# android-build

Build a Gradle Android project from the terminal — in Termux or on desktop
Linux. It is the generalized form of a per-project build script: project path,
variant, clean and install used to be hard-coded.

```bash
tools/android/android-build/run.sh [project] [options] [-- gradle args...]
```

| option | meaning |
| --- | --- |
| `-v, --variant NAME` | `debug` or `release` (default `release`) |
| `--clean` | run `clean` before `assemble` |
| `--install` | `adb install -r` every APK that was produced |
| `--daemon` | keep the Gradle daemon (default `--no-daemon`, friendlier to phones) |
| `--env` | print the detected toolchain and exit |
| `-- <args>` | extra Gradle arguments, e.g. `-- --stacktrace` |

It checks for `gradlew`, a JDK (and exports `JAVA_HOME` when it can), and an
Android SDK from `ANDROID_HOME`/`ANDROID_SDK_ROOT`, `local.properties`, or a few
common locations. After the build it reports only APKs newer than the build
start, with size and SHA-256.

```bash
tools/android/android-build/run.sh ~/jmc/JMNeXt --variant release
toolbelt run android-build -- --env
toolbelt run android-build -- --install
```

Notes:

- Needs a JDK and, for old Gradle wrappers, a matching Gradle version. On Termux
  `pkg install openjdk-17` is a good default.
- If the project needs a specific SDK inside a container, set `ANDROID_HOME` to
  that container's path.
- The script never edits the project; it only runs `./gradlew`.
