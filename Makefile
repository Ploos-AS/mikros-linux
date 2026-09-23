TARGET ?= x86-i586
PROFILE ?= minimal
OUT ?= out/$(TARGET)/$(PROFILE)

.PHONY: all info prepare rootfs image clean

all: image

info:
	@./scripts/build.sh info "$(TARGET)" "$(PROFILE)" "$(OUT)"

prepare:
	@./scripts/build.sh prepare "$(TARGET)" "$(PROFILE)" "$(OUT)"

rootfs: prepare
	@./scripts/build.sh rootfs "$(TARGET)" "$(PROFILE)" "$(OUT)"

image: rootfs
	@./scripts/build.sh image "$(TARGET)" "$(PROFILE)" "$(OUT)"

clean:
	rm -rf out
