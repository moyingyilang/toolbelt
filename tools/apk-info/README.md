# apk-info

Inspect an APK from the terminal: size, SHA-256, native ABIs, v1 signature
evidence, and — when the Android SDK is available — package identity,
versions, label, launchable activity and permissions.

```bash
tools/apk-info/run.sh app.apk
toolbelt run apk-info -- app-debug.apk
```

It needs only `unzip` (and `sha256sum` for the digest). Package details come
from `aapt2`/`aapt`: it looks on `PATH` first, then in
`$ANDROID_HOME/build-tools/*`, `$ANDROID_SDK_ROOT/build-tools/*` and
`$HOME/android-sdk/build-tools/*`.

```text
file    app-release.apk
size    4821004 bytes
sha256  ...
entries 812
abis    arm64-v8a
signed  yes (v1 evidence: 2 signature file(s))
  package: name='dev.example.app' versionCode='42' versionName='1.4.2'
  sdkVersion:'26'
  targetSdkVersion:'34'
  launchable-activity: name='dev.example.app.MainActivity'
```

The script only reads the file; it never installs or modifies the APK.
