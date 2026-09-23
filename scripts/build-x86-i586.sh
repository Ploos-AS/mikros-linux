#!/bin/sh
set -eu

. ./scripts/lib.sh
. ./versions.conf

PROFILE=${1:-minimal}
OUT=${2:-out/x86-i586/$PROFILE}
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

# BusyBox: deterministic minimal config. Start empty, append the policy
# fragment plus the core applets needed by rcS/smoke tests, then let
# olddefconfig resolve dependencies without interactive prompts.
make -C "$WORK/busybox" ARCH=x86 CROSS_COMPILE=i586-linux-musl- allnoconfig
bb="$WORK/busybox/.config"
cat configs/busybox/minimal.fragment >> "$bb"
cat >> "$bb" <<'EOF'
CONFIG_LFS=y
CONFIG_CAT=y
CONFIG_ECHO=y
CONFIG_LS=y
CONFIG_CP=y
CONFIG_MV=y
CONFIG_RM=y
CONFIG_MKDIR=y
CONFIG_CHMOD=y
CONFIG_CHOWN=y
CONFIG_LN=y
CONFIG_PS=y
CONFIG_KILL=y
CONFIG_SLEEP=y
EOF
# BusyBox 1.37 has no olddefconfig target. Feed defaults to oldconfig, then
# verify the policy-critical settings before compiling.
yes "" | make -C "$WORK/busybox" ARCH=x86 CROSS_COMPILE=i586-linux-musl- oldconfig >/dev/null || true
for s in STATIC LFS ASH SH_IS_ASH INIT FEATURE_USE_INITTAB MOUNT UMOUNT DMESG HALT POWEROFF REBOOT GETTY MDEV CAT ECHO LS CP MV RM MKDIR CHMOD CHOWN LN PS KILL SLEEP; do
    grep -q "^CONFIG_$s=y$" "$bb" || die "BusyBox config lost required CONFIG_$s"
done
make -C "$WORK/busybox" -j"$JOBS" ARCH=x86 CROSS_COMPILE=i586-linux-musl-
make -C "$WORK/busybox" ARCH=x86 CROSS_COMPILE=i586-linux-musl- CONFIG_PREFIX="$ROOT" install

# Overlay distribution-owned rootfs files.
cp -a rootfs/. "$ROOT/"
chmod +x "$ROOT/etc/init.d/rcS"
mkdir -p "$ROOT/dev" "$ROOT/proc" "$ROOT/sys" "$ROOT/run" "$ROOT/tmp" "$ROOT/root" "$ROOT/etc/mikros"
printf 'MikrOS Linux x86-i586 %s\n' "$PROFILE" > "$ROOT/etc/mikros/release"

# Kernel: i386_defconfig is only the seed; MikrOS minimum policy overrides it.
make -C "$WORK/linux" ARCH=x86 i386_defconfig
. ./scripts/lib.sh
apply_fragment "$WORK/linux" configs/kernel/x86-i586.fragment
yes "" | make -C "$WORK/linux" ARCH=x86 oldconfig >/dev/null
make -C "$WORK/linux" -j"$JOBS" ARCH=x86 CROSS_COMPILE=i586-linux-musl- bzImage

mkdir -p "$OUT/boot"
cp "$WORK/linux/arch/x86/boot/bzImage" "$OUT/boot/bzImage"

# Deterministic-enough M0 initramfs staging. Full reproducibility is qualified later.
(
    cd "$ROOT"
    find . -print | LC_ALL=C sort | cpio -o -H newc 2>/dev/null | gzip -9n
) > "$OUT/boot/initramfs.cpio.gz"

sha256sum "$OUT/boot/bzImage" "$OUT/boot/initramfs.cpio.gz" > "$OUT/SHA256SUMS"
echo "built $OUT/boot/bzImage and initramfs.cpio.gz"
