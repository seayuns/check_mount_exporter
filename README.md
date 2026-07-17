# check_mount Prometheus exporter

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

If the exporter is launched without `--config.mountpoints` then `/etc/fstab` will be parsed to identify which mountpoints to produce metrics for.

When parsing `/etc/fstab` you can exclude mountpoints using the `--config.exclude.mountpoints` and `--config.exclude.fs-types` flags.

The value for `--config.mountpoints` is comma separated while the exclude flags expect regular expressions.

`--config.check-io` enables an additional read/write accessibility probe for mounted paths.

`--config.check-io-timeout` sets the timeout for each I/O probe. The default is `30s`.

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
