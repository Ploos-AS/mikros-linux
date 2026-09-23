#!/bin/sh
set -eu

. ./versions.conf

OUT=${OUT:-out/toolchains/x86-i586}
SYSROOT="$OUT/sysroot"
WRAP="$OUT/bin"
SRC=${SRC:-sources}
JOBS=${JOBS:-2}
MUSL_SRC="$SRC/musl-$MUSL_VERSION.tar.gz"
BUILD="$OUT/build-musl"

[ -f "$MUSL_SRC" ] || { echo "missing $MUSL_SRC; run scripts/fetch-sources.sh first" >&2; exit 1; }
mkdir -p "$SYSROOT" "$WRAP"
rm -rf "$BUILD"
mkdir -p "$BUILD"
tar -xzf "$MUSL_SRC" -C "$BUILD" --strip-components=1

# Build a real i386 musl sysroot with an i586/Pentium ISA floor.
(
  cd "$BUILD"
  CC="gcc -m32 -march=pentium" ./configure --prefix=/usr --target=i386
  make -j"$JOBS"
  make DESTDIR="$(cd ../sysroot && pwd)" install
)

SYSROOT_ABS=$(cd "$SYSROOT" && pwd)
cat > "$WRAP/i586-linux-musl-gcc" <<EOF
#!/bin/sh
exec gcc -m32 -march=pentium --sysroot="$SYSROOT_ABS" -static "\$@"
EOF
chmod +x "$WRAP/i586-linux-musl-gcc"

for t in ar as ld nm objcopy objdump ranlib readelf size strings strip; do
  p=$(command -v "$t")
  ln -sf "$p" "$WRAP/i586-linux-musl-$t"
done

echo "M0 i586 musl sysroot prepared in $SYSROOT"
"$WRAP/i586-linux-musl-gcc" --version | head -1
