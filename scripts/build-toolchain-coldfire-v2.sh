#!/bin/sh
set -eu

OUT=${OUT:-out/toolchains/m68k-coldfire-v2}
JOBS=${JOBS:-2}
BUILDROOT_VERSION=2026.08
BUILD="$OUT/buildroot-$BUILDROOT_VERSION"
PREFIX_ABS="$(pwd)/$OUT/toolchain"

rm -rf "$BUILD" "$PREFIX_ABS"
mkdir -p "$OUT"

archive="$OUT/buildroot-$BUILDROOT_VERSION.tar.xz"
if [ ! -f "$archive" ]; then
    curl -fL --retry 3 -o "$archive.tmp" \
      "https://buildroot.org/downloads/buildroot-$BUILDROOT_VERSION.tar.xz"
    mv "$archive.tmp" "$archive"
fi

mkdir -p "$BUILD"
tar -xJf "$archive" -C "$BUILD" --strip-components=1

make -C "$BUILD" O="$(pwd)/$OUT/work" defconfig
KCONFIG="$(pwd)/$OUT/work/.config"
cat >> "$KCONFIG" <<'EOF'
BR2_m68k=y
BR2_m68k_cf5208=y
BR2_TOOLCHAIN_BUILDROOT_UCLIBC=y
BR2_KERNEL_HEADERS_6_12=y
BR2_GCC_VERSION_15_X=y
BR2_BINUTILS_VERSION_2_45_X=y
BR2_PACKAGE_BUSYBOX=n
BR2_TARGET_ROOTFS_TAR=n
EOF
make -C "$BUILD" O="$(pwd)/$OUT/work" olddefconfig
grep -q '^BR2_m68k_cf5208=y$' "$KCONFIG"
if grep -q '^BR2_USE_MMU=y$' "$KCONFIG"; then
    echo "ColdFire V2 toolchain unexpectedly enables MMU" >&2
    exit 1
fi
make -C "$BUILD" O="$(pwd)/$OUT/work" -j"$JOBS" toolchain

mkdir -p "$PREFIX_ABS"
cp -a "$OUT/work/host/." "$PREFIX_ABS/"

cc=$(find "$PREFIX_ABS/bin" -maxdepth 1 \( -type f -o -type l \) -name 'm68k-*-linux-uclibc*-gcc' | head -n1)
test -n "$cc" || { echo "ColdFire uClibC-ng compiler not found" >&2; exit 1; }
prefix=${cc%gcc}
for p in "${prefix}"*; do
    [ -e "$p" ] || continue
    n=${p##*/}
    n=${n#${prefix##*/}}
    ln -sf "${p##*/}" "$PREFIX_ABS/bin/m68k-linux-uclibc-$n"
done

CC="$PREFIX_ABS/bin/m68k-linux-uclibc-gcc"
test -x "$CC"
"$CC" -dumpmachine
printf 'int main(void){return 0;}\n' > "$OUT/probe.c"
"$CC" -mcpu=5208 -Os "$OUT/probe.c" -o "$OUT/probe"
file "$OUT/probe"
echo "M0 ColdFire V2/MCF5208 no-MMU uClibC-ng cross-toolchain prepared in $PREFIX_ABS"
