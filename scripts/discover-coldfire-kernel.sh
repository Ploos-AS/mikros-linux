#!/bin/sh
# Inspect pinned Linux sources without requiring the cross compiler or QEMU.
set -eu
. ./scripts/lib.sh
. ./versions.conf

SRC=${SRC:-sources}
OUT=${OUT:-out/m68k-coldfire-v2/minimal}
archive="$SRC/linux-$LINUX_VERSION.tar.xz"
[ -f "$archive" ] || die "missing $archive (run make fetch)"
need tar
need grep
need sort
need mktemp

mkdir -p "$OUT/meta"
report="$OUT/meta/kernel-discovery.txt"
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT HUP INT TERM
mkdir -p "$temp/linux"
tar -xJf "$archive" -C "$temp/linux" --strip-components=1 ||
    die "cannot unpack pinned Linux archive"
tree="$temp/linux"
[ -f "$tree/arch/m68k/Kconfig" ] ||
    die "archive lacks arch/m68k/Kconfig"

{
    printf 'Linux version: %s\n' "$LINUX_VERSION"
    printf 'Archive: %s\n' "$archive"
    sha256sum "$archive"
    echo 'Candidate m68k defconfig paths:'
    find "$tree/arch/m68k/configs" -maxdepth 1 -type f \
      \( -iname '*5208*' -o -iname '*coldfire*' -o -iname '*mcf*' \) \
      -print 2>/dev/null | LC_ALL=C sort || true
    echo 'MCF5208 references in arch/m68k:'
    grep -RInE 'M5208|MCF5208|m5208|mcf5208' \
      "$tree/arch/m68k/Kconfig"* "$tree/arch/m68k/platform" \
      "$tree/arch/m68k/configs" 2>/dev/null | head -n 120 || true
    echo 'ColdFire-related Kconfig symbols:'
    grep -RnhE --include='Kconfig*' '^[[:space:]]*(menu)?config[[:space:]]+(M5208|COLDFIRE|M68K.*NOMMU)' \
      "$tree/arch/m68k" 2>/dev/null | \
      LC_ALL=C sort -u || true
} > "$report"
cat "$report"
echo "Saved discovery evidence: $report"
echo "Discovery is not a boot or compilation PASS."
