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
# Qualify a minimal BusyBox for the no-MMU FLAT ABI.
mkdir -p "$WORK/busybox" "$OUT/rootfs"
tar -xjf "sources/busybox-$BUSYBOX_VERSION.tar.bz2" -C "$WORK/busybox" --strip-components=1
make -C "$WORK/busybox" ARCH=m68k CROSS_COMPILE="$CROSS" allnoconfig >/dev/null
bb="$WORK/busybox/.config"
for opt in STATIC ASH SH_IS_ASH CAT ECHO LS; do
    sed -i "s/^# CONFIG_$opt is not set$/CONFIG_$opt=y/" "$bb"
done
sed -i "s/^CONFIG_LFS=y$/# CONFIG_LFS is not set/" "$bb"
# Keep libc off_t and BusyBox uoff_t consistent for the uClinux ABI.
sed -i "s/^CONFIG_LFS=y$/# CONFIG_LFS is not set/" "$bb"
yes "" | make -C "$WORK/busybox" ARCH=m68k CROSS_COMPILE="$CROSS" oldconfig >/dev/null || true
grep -q "^# CONFIG_LFS is not set$" "$bb" || { echo "BusyBox LFS must be disabled" >&2; exit 1; }
for opt in STATIC ASH SH_IS_ASH CAT ECHO LS; do
    grep -q "^CONFIG_$opt=y$" "$bb" || { echo "BusyBox missing $opt" >&2; exit 1; }
done
make -C "$WORK/busybox" -j"$JOBS" ARCH=m68k CROSS_COMPILE="$CROSS" CFLAGS_busybox="-mcpu=5208"
make -C "$WORK/busybox" ARCH=m68k CROSS_COMPILE="$CROSS" CONFIG_PREFIX="$OUT/rootfs" install
file "$OUT/rootfs/bin/busybox" | tee "$OUT/boot/busybox.file"
grep -q 'BFLT executable' "$OUT/boot/busybox.file" || { echo "BusyBox is not BFLT" >&2; exit 1; }
file "$OUT/boot/vmlinux"
sha256sum "$OUT/boot/vmlinux" > "$OUT/boot/vmlinux.sha256"
echo "built MCF5208 no-MMU kernel"
