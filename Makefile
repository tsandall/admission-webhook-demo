PKG := github.com/tsandall/admission-webhook-demo
COMMIT := $(shell ./build/get-build-commit.sh)
ARCH := amd64
BUILD_IMAGE ?= golang:1.8-alpine
IMAGE ?= tsandall/admission-webhook-demo

.PHONY: all
all: image

.PHONY: build
build:
	docker run -it \
		-v $$(pwd)/.go:/go \
		-v $$(pwd):/go/src/$(PKG) \
		-v $$(pwd)/bin/linux_$(ARCH):/go/bin \
		-v $$(pwd)/.go/std/$(ARCH):/usr/local/go/pkg/linux_$(ARCH)_static \
		-w /go/src/$(PKG) \
		$(BUILD_IMAGE) \
		/bin/sh -c "ARCH=$(ARCH) COMMIT=$(COMMIT) PKG=$(PKG) ./build/build.sh"

.PHONY: image
image: build
	docker build -t $(IMAGE):$(COMMIT) -f Dockerfile .
	docker tag $(IMAGE):$(COMMIT) $(IMAGE):latest
