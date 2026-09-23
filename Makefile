TARGET ?= x86-i586
PROFILE ?= minimal
OUT ?= out/$(TARGET)/$(PROFILE)

.PHONY: all info prepare rootfs image build smoke fetch clean

all: build

info:
	@./scripts/build.sh info "$(TARGET)" "$(PROFILE)" "$(OUT)"

fetch:
	@./scripts/fetch-sources.sh

prepare:
	@./scripts/build.sh prepare "$(TARGET)" "$(PROFILE)" "$(OUT)"

rootfs: prepare
	@./scripts/build.sh rootfs "$(TARGET)" "$(PROFILE)" "$(OUT)"

image: rootfs
	@./scripts/build.sh image "$(TARGET)" "$(PROFILE)" "$(OUT)"

build:
ifeq ($(TARGET),x86-i586)
	@./scripts/build-x86-i586.sh "$(PROFILE)" "$(OUT)"
else
	@echo "target $(TARGET) has no qualified builder yet" >&2
	@exit 2
endif

smoke: build
ifeq ($(TARGET),x86-i586)
	@./scripts/qemu-smoke-x86.sh "$(OUT)"
else
	@echo "target $(TARGET) has no smoke test yet" >&2
	@exit 2
endif

clean:
	rm -rf out
