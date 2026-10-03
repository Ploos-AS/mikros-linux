#!/bin/sh
set -eu

. ./scripts/lib.sh
. ./versions.conf

PROFILE=${1:-minimal}
OUT=${2:-out/x86-i586/$PROFILE}
# Keep all derived paths absolute: BusyBox install runs under make -C and
# initramfs creation changes directory into the rootfs.
case "$OUT" in
    /*) ;;
    *) OUT="$PWD/$OUT" ;;
esac
JOBS=${JOBS:-2}
SRC=${SRC:-sources}
WORK="$OUT/work"
ROOT="$OUT/rootfs"

[ "$PROFILE" = minimal ] || die "x86 M0 builder currently qualifies minimal only"

for t in make tar xz bzip2 cpio gzip; do need "$t"; done
need i586-linux-musl-gcc

mkdir -p "$WORK" "$ROOT"
linux_tar="$SRC/linux-$LINUX_VERSION.tar.xz"
busybox_tar="$SRC/busybox-$BUSYBOX_VERSION.tar.bz2"
[ -f "$linux_tar" ] || die "run scripts/fetch-sources.sh first"
[ -f "$busybox_tar" ] || die "run scripts/fetch-sources.sh first"

rm -rf "$WORK/linux" "$WORK/busybox"
mkdir -p "$WORK/linux" "$WORK/busybox"
tar -xJf "$linux_tar" -C "$WORK/linux" --strip-components=1
tar -xjf "$busybox_tar" -C "$WORK/busybox" --strip-components=1

make -C "$WORK/busybox" ARCH=x86 CROSS_COMPILE=i586-linux-musl- allnoconfig >/dev/null
bb="$WORK/busybox/.config"
for s in STATIC LFS ASH SH_IS_ASH INIT FEATURE_USE_INITTAB MOUNT UMOUNT DMESG HALT POWEROFF REBOOT GETTY MDEV CAT ECHO LS CP MV RM MKDIR CHMOD CHOWN LN PS KILL SLEEP; do
    sed -i "s/^# CONFIG_$s is not set$/CONFIG_$s=y/" "$bb"
done
yes "" | make -C "$WORK/busybox" ARCH=x86 CROSS_COMPILE=i586-linux-musl- oldconfig >/dev/null || true
grep -q '^# CONFIG_TC is not set$' "$bb" || die "BusyBox minimal unexpectedly enabled CONFIG_TC"
for s in STATIC LFS ASH SH_IS_ASH INIT FEATURE_USE_INITTAB MOUNT UMOUNT DMESG HALT POWEROFF REBOOT GETTY MDEV CAT ECHO LS CP MV RM MKDIR CHMOD CHOWN LN PS KILL SLEEP; do
    grep -q "^CONFIG_$s=y$" "$bb" || die "BusyBox config lost required CONFIG_$s"
done

make -C "$WORK/busybox" -j"$JOBS" V=1 ARCH=x86 CROSS_COMPILE=i586-linux-musl-
make -C "$WORK/busybox" ARCH=x86 CROSS_COMPILE=i586-linux-musl- CONFIG_PREFIX="$ROOT" install

cp -a rootfs/. "$ROOT/"
chmod +x "$ROOT/etc/init.d/rcS"
mkdir -p "$ROOT/dev" "$ROOT/proc" "$ROOT/sys" "$ROOT/run" "$ROOT/tmp" "$ROOT/root" "$ROOT/etc/mikros"
printf 'MikrOS Linux x86-i586 %s\n' "$PROFILE" > "$ROOT/etc/mikros/release"

make -C "$WORK/linux" ARCH=x86 i386_defconfig
apply_fragment "$WORK/linux" configs/kernel/x86-i586.fragment

# scripts/config changes a Kconfig choice in the seed .config. olddefconfig
# then resolves dependencies without interactively replacing that choice.
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable M686
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --enable M586
make -C "$WORK/linux" ARCH=x86 olddefconfig >/dev/null

# Enforce the minimal M0 hardening policy after Kconfig has resolved the CPU.
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable GCC_PLUGIN_STRUCTLEAK
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable GCC_PLUGIN_STRUCTLEAK_USER
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable GCC_PLUGIN_STRUCTLEAK_BYREF
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable GCC_PLUGIN_STRUCTLEAK_BYREF_ALL
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable GCC_PLUGIN_STACKLEAK
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --enable INIT_STACK_NONE
"$WORK/linux/scripts/config" --file "$WORK/linux/.config" --disable GCC_PLUGINS

grep -q '^CONFIG_M586=y$' "$WORK/linux/.config" || die "kernel config did not retain CONFIG_M586"
if grep -q '^CONFIG_M686=y$' "$WORK/linux/.config"; then
    die "kernel config unexpectedly selected CONFIG_M686"
fi
grep -q '^# CONFIG_GCC_PLUGINS is not set$' "$WORK/linux/.config" ||
    die "kernel config unexpectedly enabled CONFIG_GCC_PLUGINS"
if grep -Eq '^CONFIG_GCC_PLUGIN_STRUCTLEAK(_BYREF(_ALL)?|_USER)?=y$' "$WORK/linux/.config"; then
    die "kernel config unexpectedly retained structleak hardening"
fi

make -C "$WORK/linux" -j"$JOBS" V=1 ARCH=x86 CROSS_COMPILE=i586-linux-musl- bzImage

mkdir -p "$OUT/boot"
cp "$WORK/linux/arch/x86/boot/bzImage" "$OUT/boot/bzImage"
(
    cd "$ROOT"
    find . -print0 | LC_ALL=C sort -z | cpio --null -o -H newc 2>/dev/null | gzip -9n
) > "$OUT/boot/initramfs.cpio.gz"

# A valid BusyBox rootfs is much larger than an empty cpio trailer. Catch
# truncated/empty initramfs artifacts before spending time on QEMU boot tests.
initramfs_size=$(wc -c < "$OUT/boot/initramfs.cpio.gz")
[ "$initramfs_size" -gt 65536 ] ||
    die "initramfs unexpectedly small: $initramfs_size bytes"
gzip -dc "$OUT/boot/initramfs.cpio.gz" | cpio -t 2>/dev/null | grep -q '^sbin/init$' ||
    die "initramfs is missing sbin/init"

sha256sum "$OUT/boot/bzImage" "$OUT/boot/initramfs.cpio.gz" > "$OUT/SHA256SUMS"
echo "built $OUT/boot/bzImage and initramfs.cpio.gz"
