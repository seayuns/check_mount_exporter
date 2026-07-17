# Check mount Prometheus exporter

The `check_mount_exporter` produces metrics about mount points mount status and if that mountpoint is read-only or read-write.

This exporter by default listens on port `9304` and all metrics are exposed via the `/metrics` endpoint.

Example of metrics exposed by this exporter:

```
check_mount_status{mountpoint="/",rw="rw"} 1
check_mount_status{mountpoint="/boot",rw="rw"} 1
check_mount_status{mountpoint="/opt",rw="rw"} 1
check_mount_status{mountpoint="/tmp",rw="rw"} 1
check_mount_status{mountpoint="/var",rw="rw"} 1
```

When `--config.check-io` is enabled, the exporter also probes the mounted path itself and emits:

```
check_mount_io_status{mountpoint="/var",rw="rw"} 1
```

# Usage

If `--config.mountpoints` is empty, the exporter parses `/etc/fstab` under `--path.rootfs` and uses those mountpoints instead.

| Flag | Default | Description |
| --- | --- | --- |
| `--config.mountpoints` | empty | Comma-separated list of mountpoints to check. |
| `--config.exclude.mountpoints` | `^/(dev|proc|sys|var/lib/docker/.+)($|/)` | Regex for mountpoints to skip when reading `/etc/fstab`. |
| `--config.exclude.fs-types` | `^(proc|procfs|sysfs|swap)$` | Regex for filesystem types to skip when reading `/etc/fstab`. |
| `--config.check-io` | `false` | Enable read/write accessibility probes for mounted paths. |
| `--config.check-io-timeout` | `30s` | Timeout for each I/O probe. |
| `--path.rootfs` | `/` | Root filesystem path used to read `/etc/fstab` and `/proc/mounts`. |
| `--web.listen-address` | `:9304` | Address for the HTTP server. |
| `--web.disable-exporter-metrics` | `false` | Disable exporter self-metrics such as `go_*`, `process_*`, and `promhttp_*`. |
| `--log.level` | `info` | Minimum log severity. One of `debug`, `info`, `warn`, `error`. |
| `--log.format` | `logfmt` | Log output format. One of `logfmt`, `json`. |

The exclude flags expect regular expressions, not comma-separated lists.

When `--config.check-io` is enabled, the exporter also probes the mounted path itself and emits `check_mount_io_status`.

For read-write mounts, the probe creates a temporary file, writes and reads it back, then removes it. For read-only mounts, it verifies the directory is readable.

## Docker

Build the image for the current platform:

```
docker build -t check_mount_exporter:latest .
```

Build multi-architecture images for `linux/amd64` and `linux/arm64`:

```
docker buildx build --platform linux/amd64,linux/arm64 -t check_mount_exporter:latest .
```

Example of running the Docker container:

```
docker run -d -p 9304:9304 -v "/:/host:ro,rslave" check_mount_exporter:latest --path.rootfs=/host
```

## Install

Download the [latest release](https://github.com/seayuns/check_mount_exporter/releases)

Tagged releases publish `linux/amd64` and `linux/arm64` tar.gz assets to GitHub Release.

## Build from source

To produce the `check_mount_exporter` binary:

```
make build
```

GitHub Actions uploads Linux binaries for `amd64` and `arm64` as workflow artifacts.
