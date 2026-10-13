#!/bin/sh
# Inspect the *pinned* kernel archive for MCF5208 / ColdFire board support.
# Discovery only: no boot-qualification claim.
set -eu
. ./scripts/lib.sh
. ./versions.conf

SRC=${SRC:-sources}
archive="$SRC/linux-$LINUX_VERSION.tar.xz"
[ -f "$archive" ] || die "missing $archive (run make fetch)"
need tar
need grep
need sort

echo "Kernel archive: $archive"
echo "Candidate config paths (not necessarily working):"
tar -tJf "$archive" |
  grep -Ei '/(arch/m68k/configs/[^/]*(m5208|5208|coldfire|mcf)[^/]*|arch/m68k/platform/[^/]*(5208|coldfire)[^/]*)$' |
  LC_ALL=C sort || true

echo "Relevant MCF5208 source paths:"
tar -tJf "$archive" |
  grep -Ei '/arch/m68k/.*(m5208|mcf5208|5208evb)' |
  LC_ALL=C sort || true

echo "Review config symbols and QEMU image loading before enabling build."
