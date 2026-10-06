#!/bin/sh
set -eu

. ./scripts/lib.sh
. ./versions.conf

PROFILE=${1:-minimal}
OUT=${2:-out/m68k/$PROFILE}
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT" ;; esac
JOBS=${JOBS:-2}
SRC=${SRC:-sources}
WORK="$OUT/work"
ROOT="$OUT/rootfs"
TC=${MIKROS_M68K_TOOLCHAIN:-$PWD/out/toolchains/m68k/toolchain}
CROSS="$TC/bin/m68k-linux-uclibc-"

[ "$PROFILE" = minimal ] || die "m68k M0 builder currently qualifies minimal only"
for t in make tar bzip2 cpio gzip; do need "$t"; done
[ -x "${CROSS}gcc" ] || die "missing m68k toolchain; run scripts/build-toolchain-m68k.sh first"

busybox_tar="$SRC/busybox-$BUSYBOX_VERSION.tar.bz2"
[ -f "$busybox_tar" ] || die "run scripts/fetch-sources.sh first"

rm -rf "$WORK/busybox" "$ROOT"
mkdir -p "$WORK/busybox" "$ROOT"
tar -xjf "$busybox_tar" -C "$WORK/busybox" --strip-components=1

make -C "$WORK/busybox" ARCH=m68k CROSS_COMPILE="$CROSS" allnoconfig >/dev/null
bb="$WORK/busybox/.config"
for s in STATIC LFS ASH SH_IS_ASH INIT FEATURE_USE_INITTAB MOUNT UMOUNT DMESG HALT POWEROFF REBOOT GETTY MDEV CAT ECHO LS CP MV RM MKDIR CHMOD CHOWN LN PS KILL SLEEP; do
    sed -i "s/^# CONFIG_$s is not set$/CONFIG_$s=y/" "$bb"
done
yes "" | make -C "$WORK/busybox" ARCH=m68k CROSS_COMPILE="$CROSS" oldconfig >/dev/null || true
for s in STATIC ASH SH_IS_ASH INIT FEATURE_USE_INITTAB CAT ECHO LS; do
    grep -q "^CONFIG_$s=y$" "$bb" || die "BusyBox config lost required CONFIG_$s"
done

make -C "$WORK/busybox" -j"$JOBS" ARCH=m68k CROSS_COMPILE="$CROSS" CFLAGS_busybox="-m68020"
make -C "$WORK/busybox" ARCH=m68k CROSS_COMPILE="$CROSS" CONFIG_PREFIX="$ROOT" install

cp -a rootfs/. "$ROOT/"
chmod +x "$ROOT/etc/init.d/rcS"
mkdir -p "$ROOT/dev" "$ROOT/proc" "$ROOT/sys" "$ROOT/run" "$ROOT/tmp" "$ROOT/root" "$ROOT/etc/mikros"
printf 'MikrOS Linux m68k-68020 %s\n' "$PROFILE" > "$ROOT/etc/mikros/release"

mkdir -p "$OUT/boot"
(
    cd "$ROOT"
    find . -print0 | LC_ALL=C sort -z | cpio --null -o -H newc 2>/dev/null | gzip -9n
) > "$OUT/boot/initramfs.cpio.gz"

gzip -dc "$OUT/boot/initramfs.cpio.gz" | cpio -t 2>/dev/null | grep -q '^sbin/init$' ||
    die "initramfs is missing sbin/init"
file "$ROOT/bin/busybox" | tee "$OUT/busybox.file"
sha256sum "$OUT/boot/initramfs.cpio.gz" > "$OUT/SHA256SUMS"
echo "built m68k/68020 minimal rootfs and initramfs"
