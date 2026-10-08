#!/bin/sh
set -eu

. ./versions.conf

OUT=${OUT:-out/m68k-coldfire-v2/minimal}
JOBS=${JOBS:-2}
TC=${TC:-out/toolchains/m68k-coldfire-v2/toolchain}
TC="$(cd "$TC" && pwd)"
CROSS="$TC/bin/m68k-linux-uclibc-"
WORK="$OUT/work"

test -x "${CROSS}gcc" || { echo "ColdFire toolchain missing: ${CROSS}gcc" >&2; exit 1; }
test -f "sources/linux-$LINUX_VERSION.tar.xz" || { echo "missing pinned Linux source; run fetch-sources.sh" >&2; exit 1; }

rm -rf "$WORK/linux"
mkdir -p "$WORK/linux" "$OUT/boot"
tar -xJf "sources/linux-$LINUX_VERSION.tar.xz" -C "$WORK/linux" --strip-components=1

make -C "$WORK/linux" ARCH=m68k CROSS_COMPILE="$CROSS" m5208evb_defconfig
grep -q '^# CONFIG_MMU is not set$' "$WORK/linux/.config" || { echo "MCF5208 kernel unexpectedly enables MMU" >&2; exit 1; }
grep -q '^CONFIG_BINFMT_FLAT=y$' "$WORK/linux/.config" || { echo "MCF5208 kernel lacks FLAT binary support" >&2; exit 1; }
grep -q '^CONFIG_SERIAL_MCF_CONSOLE=y$' "$WORK/linux/.config" || { echo "MCF5208 kernel lacks serial console" >&2; exit 1; }

make -C "$WORK/linux" -j"$JOBS" ARCH=m68k CROSS_COMPILE="$CROSS" vmlinux
cp "$WORK/linux/vmlinux" "$OUT/boot/vmlinux"
printf '#include <unistd.h>\nint main(void) { static const char msg[] = "MikrOS ColdFire V2\\n"; return write(1, msg, sizeof(msg)-1) < 0; }\n' > "$OUT/hello.c"
"${CROSS}gcc" -mcpu=5208 -Os -static "$OUT/hello.c" -o "$OUT/boot/hello"
file "$OUT/boot/hello" | tee "$OUT/boot/hello.file"
grep -q 'BFLT executable' "$OUT/boot/hello.file" || { echo "ColdFire userspace probe is not BFLT" >&2; exit 1; }
file "$OUT/boot/vmlinux"
sha256sum "$OUT/boot/vmlinux" > "$OUT/boot/vmlinux.sha256"
echo "built MCF5208 no-MMU kernel"
