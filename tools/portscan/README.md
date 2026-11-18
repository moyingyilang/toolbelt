# portscan

Parallel TCP connect scanner that needs nothing but bash. It was extracted from
a one-off local script where the target IP and port range were hard-coded; the
host, ports, concurrency and timeout are now arguments.

```bash
tools/portscan/run.sh <host> <ports> [options]
```

| option | meaning |
| --- | --- |
| `-j, --jobs N` | concurrent probes (default 64, max 1024) |
| `-t, --timeout SEC` | per-probe connect timeout via `timeout(1)` (0 = none) |
| `-q, --quiet` | suppress the summary on stderr |
| `-h, --help` | usage |

Ports accept single ports, ranges, and mixes: `22,80,443`, `1-1024`,
`22,8000-8100,443`. Results are printed as one `OPEN <port>` line each, sorted.

```bash
# LAN sweep
tools/portscan/run.sh 192.168.1.1 1-1024

# A single service, no summary
tools/portscan/run.sh example.com 443 -q

# Through toolbelt
toolbelt run portscan -- 127.0.0.1 8000-8100 -j 32
```

Notes:

- Uses bash's `/dev/tcp` pseudo-device, so the host must run bash (Termux has it).
- The scan is a plain TCP connect: it is not stealthy and it talks to every port
  in the range. Only scan hosts you are allowed to probe.
- Without `--timeout`, a firewall that silently drops packets can make the scan
  wait for the kernel's connect timeout; prefer `--timeout 1` for WAN targets.
