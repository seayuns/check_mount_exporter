# syntax=docker/dockerfile:1.7

FROM --platform=$BUILDPLATFORM golang:1.22-alpine AS build

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=dev
ARG REVISION=unknown
ARG BRANCH=unknown
ARG BUILD_DATE=unknown

WORKDIR /src

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -tags netgo \
    -ldflags '-s -w -extldflags "-static" \
    -X github.com/prometheus/common/version.Version='"${VERSION}"' \
    -X github.com/prometheus/common/version.Revision='"${REVISION}"' \
    -X github.com/prometheus/common/version.Branch='"${BRANCH}"' \
    -X github.com/prometheus/common/version.BuildUser=docker \
    -X github.com/prometheus/common/version.BuildDate='"${BUILD_DATE}"'' \
    -o /out/check_mount_exporter .

FROM scratch

LABEL org.opencontainers.image.authors="seayuns@163.com" \
      org.opencontainers.image.title="check_mount_exporter" \
      org.opencontainers.image.description="Prometheus exporter for mount point status and I/O checks"

COPY --from=build /out/check_mount_exporter /check_mount_exporter
EXPOSE 9304
ENTRYPOINT ["/check_mount_exporter"]
