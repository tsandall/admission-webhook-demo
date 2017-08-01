#!/bin/sh

set -ex

GOARCH=${ARCH} go install -ldflags "-X ${PKG}/version.Git=${COMMIT}"
