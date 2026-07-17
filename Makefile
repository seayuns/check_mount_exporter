GO ?= go
BINARY := check_mount_exporter
PKGS := ./...
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
REVISION ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
BUILD_USER ?= $(shell whoami)@$(shell hostname)
BUILD_DATE ?= $(shell date -u +%Y%m%d-%H:%M:%S)
LDFLAGS := -s -w -extldflags "-static" \
	-X github.com/prometheus/common/version.Version=$(VERSION) \
	-X github.com/prometheus/common/version.Revision=$(REVISION) \
	-X github.com/prometheus/common/version.Branch=$(BRANCH) \
	-X github.com/prometheus/common/version.BuildUser=$(BUILD_USER) \
	-X github.com/prometheus/common/version.BuildDate=$(BUILD_DATE)

.PHONY: build
build:
	$(GO) build -trimpath -tags netgo -ldflags '$(LDFLAGS)' -o $(BINARY) .

.PHONY: test
test:
	$(GO) test ./...

.PHONY: coverage
coverage:
	$(GO) test -race -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic ./...

.PHONY: clean
clean:
	rm -f $(BINARY) coverage.txt
