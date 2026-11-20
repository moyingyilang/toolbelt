# jdk-install

Install a Temurin JDK into a user directory. Queries the
[Adoptium API](https://api.adoptium.net/) for the latest build of one major
version, verifies the published SHA-256, extracts it under `--dir`, and prints
the exports to add to your shell.

```bash
tools/toolchain/jdk-install/run.sh --dry-run
tools/toolchain/jdk-install/run.sh --version 21
toolbelt run jdk-install -- --version 17
```

| option | meaning |
| --- | --- |
| `--version N` | JDK major version (default 21) |
| `--dir DIR` | install root (default `~/.local/opt`) |
| `--dry-run` | print the release URL and exit |

Supported hosts: Linux x86_64 and aarch64. Requires `curl`/`wget`, `tar` and
`sha256sum`.

**Termux note:** these are glibc builds and will not run on Android/bionic.
Use `pkg install openjdk-17` there instead; the script refuses with that hint.

Typical output:

```text
querying https://api.adoptium.net/v3/assets/latest/21/hotspot?architecture=aarch64&image_type=jdk&os=linux&vendor=eclipse
release    .../OpenJDK21U-jdk_aarch64_linux_hotspot_....tar.gz
sha256     ...
checksum   ok
installed /home/user/.local/opt/jdk-21.0.x+y
export JAVA_HOME="/home/user/.local/opt/jdk-21.0.x+y"
export PATH="$JAVA_HOME/bin:$PATH"
```
