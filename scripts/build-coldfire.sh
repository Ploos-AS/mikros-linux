#!/bin/sh
# MCF5208 no-MMU build preparation. Intentionally fail-closed until a
# kernel config and boot format are validated against the pinned Linux tree.
set -eu
. ./scripts/lib.sh
. ./versions.conf
. ./targets/m68k-coldfire-v2.conf

PROFILE=${1:-minimal}
OUT=${2:-out/m68k-coldfire-v2/$PROFILE}
[ "$PROFILE" = minimal ] || die "ColdFire M0 currently accepts minimal only"
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT";; esac
SRC=${SRC:-sources}
WORK="$OUT/work"
KERNEL_ARCH=m68k
[ "$MIKROS_EXECUTION_MODEL" = nommu ] || die "target must be no-MMU"

sh ./scripts/preflight-coldfire.sh
linux_tar="$SRC/linux-$LINUX_VERSION.tar.xz"
busybox_tar="$SRC/busybox-$BUSYBOX_VERSION.tar.bz2"
[ -f "$linux_tar" ] || die "missing $linux_tar; run make fetch"
[ -f "$busybox_tar" ] || die "missing $busybox_tar; run make fetch"

mkdir -p "$WORK" "$OUT/meta"
printf 'target=m68k-coldfire-v2\nprofile=%s\nlinux=%s\nbusybox=%s\n' \
  "$PROFILE" "$LINUX_VERSION" "$BUSYBOX_VERSION" > "$OUT/meta/build.conf"
sha256sum "$linux_tar" "$busybox_tar" > "$OUT/meta/source-sha256.txt"

# Do not guess a defconfig: availability of an m5208 CPU compiler does not
# establish a working Linux board configuration or image loading contract.
echo "Prepared ColdFire source inputs at $OUT" >&2
# Extract the pinned kernel for inspection; no kernel compilation is claimed.
mkdir -p "$WORK/linux"
tar -xJf "$linux_tar" -C "$WORK/linux" --strip-components=1
[ -f "$WORK/linux/arch/m68k/Kconfig" ] || die "kernel archive lacks arch/m68k/Kconfig"
{
  echo "Linux $LINUX_VERSION m68k configuration candidates:"
  find "$WORK/linux/arch/m68k/configs" -maxdepth 1 -type f \
    \( -iname "*5208*" -o -iname "*coldfire*" -o -iname "*mcf*" \) -print 2>/dev/null || true
  echo "MCF5208 references in m68k board/platform code:"
  grep -Rln -E "M5208|MCF5208|m5208|mcf5208" \
    "$WORK/linux/arch/m68k/Kconfig" "$WORK/linux/arch/m68k/platform" \
    "$WORK/linux/arch/m68k/configs" 2>/dev/null || true
} > "$OUT/meta/kernel-discovery.txt"
echo "Kernel discovery report: $OUT/meta/kernel-discovery.txt" >&2
echo "BLOCKED: select and validate an upstream MCF5208 Linux no-MMU kernel config," >&2
echo "then implement the compatible rootfs, image format and QEMU boot runner." >&2
exit 3
