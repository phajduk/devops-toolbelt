IMAGE_NAME ?= devops-toolbelt
TAG ?= latest
BUILD_CONTEXT ?= .
BUILDX_BUILDER ?= devops-toolbelt-builder

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make build          # Local build for current architecture"
	@echo "  make build-amd64    # Build and load linux/amd64 image via buildx"
	@echo "  make build-arm64    # Build and load linux/arm64 image via buildx"
	@echo "  make build-cross    # Build amd64 and arm64 images sequentially"
	@echo "  make ensure-builder # Create buildx builder if missing"

.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(TAG) $(BUILD_CONTEXT)

.PHONY: ensure-builder
ensure-builder:
	@if ! docker buildx inspect $(BUILDX_BUILDER) >/dev/null 2>&1; then \
		docker buildx create --name $(BUILDX_BUILDER) --use; \
	else \
		docker buildx use $(BUILDX_BUILDER); \
	fi

.PHONY: build-amd64
build-amd64: ensure-builder
	docker buildx build --builder $(BUILDX_BUILDER) --platform linux/amd64 --load \
		-t $(IMAGE_NAME):$(TAG)-amd64 $(BUILD_CONTEXT)

.PHONY: build-arm64
build-arm64: ensure-builder
	docker buildx build --builder $(BUILDX_BUILDER) --platform linux/arm64 --load \
		-t $(IMAGE_NAME):$(TAG)-arm64 $(BUILD_CONTEXT)

.PHONY: build-cross
build-cross: build-amd64 build-arm64
