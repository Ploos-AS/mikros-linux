#!/bin/sh
set -eu

OUT=${1:-out/x86-i586/minimal}
KERNEL="$OUT/boot/bzImage"
INITRD="$OUT/boot/initramfs.cpio.gz"

[ -f "$KERNEL" ] || { echo "missing $KERNEL" >&2; exit 1; }
[ -f "$INITRD" ] || { echo "missing $INITRD" >&2; exit 1; }
command -v qemu-system-i386 >/dev/null 2>&1 || { echo "missing qemu-system-i386" >&2; exit 1; }

log="$OUT/qemu-smoke.log"
rm -f "$log"

# timeout success is acceptable only if the expected userspace banner appeared.
set +e
timeout 20 qemu-system-i386 \
  -M pc -cpu pentium -m 32M \
  -kernel "$KERNEL" -initrd "$INITRD" \
  -append "console=ttyS0 rdinit=/sbin/init" \
  -nographic -no-reboot >"$log" 2>&1
rc=$?
set -e

grep -q "MikrOS Linux" "$log" || {
    cat "$log"
    echo "FAIL: MikrOS userspace banner not observed" >&2
    exit 1
}

echo "PASS: x86-i586/minimal reached MikrOS userspace (qemu rc=$rc)"
