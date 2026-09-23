#!/bin/sh
set -eu

OUT=${OUT:-out/toolchains/x86-i586}
JOBS=${JOBS:-2}
MCM_COMMIT=227df8b99103f9c59f6570babf892978e293082f
BUILD="$OUT/musl-cross-make"
PREFIX_ABS="$(pwd)/$OUT/cross"

rm -rf "$BUILD" "$PREFIX_ABS"
mkdir -p "$OUT"

# Build a genuine GCC/binutils/musl cross-toolchain. The previous M0 bootstrap
# wrapper around host gcc -m32 could mix host ABI assumptions with musl and is
# deliberately retired.
git clone -q https://github.com/richfelker/musl-cross-make.git "$BUILD"
git -C "$BUILD" checkout -q "$MCM_COMMIT"

cat > "$BUILD/config.mak" <<EOF
TARGET = i486-linux-musl
OUTPUT = $PREFIX_ABS
MUSL_VER = 1.2.5
LINUX_VER = 6.15.7
DL_CMD = curl -fL --retry 5 --retry-delay 2 -o
COMMON_CONFIG += --disable-nls
COMMON_CONFIG += CFLAGS="-g0 -Os" CXXFLAGS="-g0 -Os"
GCC_CONFIG += --with-arch=pentium --with-tune=generic
GCC_CONFIG += --disable-libquadmath --disable-decimal-float --disable-libitm --disable-lto
EOF

make -C "$BUILD" -j"$JOBS"
make -C "$BUILD" install

# The compiler bootstrap uses a musl-cross-make-supported UAPI snapshot.
# Replace those installed headers with MikrOS' pinned kernel UAPI so target
# userspace is built against the same 6.12.58 baseline as the qualified kernel.
LINUX_SRC="sources/linux-6.12.58.tar.xz"
LINUX_HDR="$OUT/linux-headers"
SYSROOT="$PREFIX_ABS/i486-linux-musl"
test -f "$LINUX_SRC" || { echo "missing $LINUX_SRC" >&2; exit 1; }
rm -rf "$LINUX_HDR"
mkdir -p "$LINUX_HDR"
tar -xJf "$LINUX_SRC" -C "$LINUX_HDR" --strip-components=1
rm -rf "$SYSROOT/include/linux" "$SYSROOT/include/asm" "$SYSROOT/include/asm-generic"
make -C "$LINUX_HDR" ARCH=x86 headers_install INSTALL_HDR_PATH="$SYSROOT"
test -f "$SYSROOT/include/linux/kd.h" || { echo "MikrOS pinned UAPI install failed" >&2; exit 1; }

# MikrOS names the qualified platform x86-i586. Keep that stable while the
# canonical GNU target tuple remains i486-linux-musl; GCC itself is configured
# with a Pentium/i586 ISA floor above.
mkdir -p "$OUT/bin"
for p in "$PREFIX_ABS"/bin/i486-linux-musl-*; do
    n=${p##*/}
    n=${n#i486-linux-musl-}
    ln -sf "../cross/bin/i486-linux-musl-$n" "$OUT/bin/i586-linux-musl-$n"
done

test -x "$OUT/bin/i586-linux-musl-gcc"
"$OUT/bin/i586-linux-musl-gcc" -dumpmachine
"$OUT/bin/i586-linux-musl-gcc" -Q --help=target 2>/dev/null | grep -E 'march=.*pentium|march=.*i586' || true
echo "M0 genuine i586 musl cross-toolchain prepared in $PREFIX_ABS"
