#!/bin/sh
set -eu

OUT=${1:-out/m68k/minimal}
KERNEL="$OUT/boot/vmlinux"
INITRD="$OUT/boot/initramfs.cpio.gz"
LOG="$OUT/qemu-smoke.log"

command -v qemu-system-m68k >/dev/null 2>&1 || { echo "missing qemu-system-m68k" >&2; exit 1; }
[ -f "$KERNEL" ] || { echo "missing $KERNEL" >&2; exit 1; }
[ -f "$INITRD" ] || { echo "missing $INITRD" >&2; exit 1; }

set +e
timeout 30s qemu-system-m68k \
  -M virt \
  -m 128M \
  -nographic \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "console=ttyGF0 rdinit=/etc/init.d/rcS" \
  >"$LOG" 2>&1
rc=$?
set -e

cat "$LOG"
grep -q "MikrOS Linux" "$LOG" || {
  echo "m68k QEMU smoke did not reach MikrOS userspace (qemu rc=$rc)" >&2
  exit 1
}
echo "m68k QEMU smoke PASS (qemu rc=$rc)"
