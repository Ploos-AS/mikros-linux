#!/bin/sh
# ColdFire V2 host/toolchain preflight. Does not claim kernel boot support.
set -eu
. ./scripts/lib.sh
. ./versions.conf
. ./targets/m68k-coldfire-v2.conf

[ "${MIKROS_EXECUTION_MODEL}" = nommu ] || die "ColdFire target must be no-MMU"
[ "${MIKROS_QEMU_MACHINE}" = mcf5208evb ] || die "unexpected QEMU machine"
[ "${MIKROS_CROSS}" = m68k-linux-uclibc- ] || die "unexpected cross prefix"

for tool in make tar xz bzip2 cpio gzip sha256sum python3; do need "$tool"; done
need "${MIKROS_CROSS}gcc"
need "${MIKROS_CROSS}readelf"
need qemu-system-m68k

machine_list=$(qemu-system-m68k -machine help)
printf '%s\n' "$machine_list" | grep -Eq '^[[:space:]]*mcf5208evb([[:space:]]|$)' ||
    die "installed QEMU lacks mcf5208evb machine"

printf 'ColdFire preflight OK\n'
printf 'kernel=%s busybox=%s uclibc-ng=%s\n' "$LINUX_VERSION" "$BUSYBOX_VERSION" "$UCLIBC_NG_VERSION"
"${MIKROS_CROSS}gcc" --version | head -n 1
qemu-system-m68k --version | head -n 1
echo "NOTE: preflight does not build or boot an image"
