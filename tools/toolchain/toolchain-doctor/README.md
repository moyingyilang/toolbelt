# toolchain-doctor

Check a build toolchain in one pass: JDK/JAVA_HOME, Gradle, Android SDK
(`build-tools`, `platforms`, `sdkmanager`, `NDK`, `adb`), C/C++
(`cc`, `make`, `cmake`, `zlib`), and Rust/Go/Node/Python. Missing pieces come
with install hints for Termux or Debian/Fedora.

```bash
tools/toolchain/toolchain-doctor/run.sh
toolbelt run toolchain-doctor
```

```text
toolchain-doctor — build toolchain check

host        Linux aarch64
family      termux
  ✓ pkg-config   0.29.2
  ✓ git          git version 2.51.0
...
JVM
  ✓ java         openjdk version "17.0.16" ...
  ✗ make         missing — pkg install make
...
toolchain-doctor: 1 missing, 3 warnings
```

Exit code is non-zero only when a critical piece is missing (`java`, `cc`,
`make`); everything else is a warning. The script is read-only.
