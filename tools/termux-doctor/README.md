# termux-doctor

Check an Android/Termux environment for the traps that break toolchains on the
device: hard links denied by sepolicy, the small default Node heap, missing
wheels, locale assumptions, storage permissions and the Android toolchain.

```bash
tools/termux-doctor/run.sh
toolbelt run termux-doctor
```

Each line is a check: `✓` fine, `!` warning, `✗` failed. The exit code is
non-zero only when something is actually broken; warnings are normal on Termux
(for example, `link(2)` being denied is expected, and tools must fall back to
`rename(2)`).

```text
termux-doctor — environment check

  ✓ bash 5.3.20(1)-release
  ✓ locale: en_US.UTF-8
  ✓ Termux prefix: /data/data/com.termux/files/usr
  ! hard links denied (Android sepolicy); tools using link(2) need a rename fallback
  ✓ $HOME free space: 8120 MiB
  ✓ bash /dev/tcp works
  ✓ node: v24.22.2
  ! node runs with the default heap; for big builds try --max-old-space-size=4096
  ! adb not installed (pkg install android-tools)
  ...
```

It is read-only: it creates one temp directory for the hard-link test and
removes it immediately.
