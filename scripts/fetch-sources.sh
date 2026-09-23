#!/bin/sh
set -eu

. ./versions.conf

dest=${1:-sources}
mkdir -p "$dest"

fetch() {
  url=$1
  output=$2
  if [ -f "$output" ]; then
    echo "using cached $output"
    return
  fi
  echo "fetching $url"
  curl -fL --retry 3 -o "$output.tmp" "$url"
  mv "$output.tmp" "$output"
}

fetch "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$LINUX_VERSION.tar.xz" "$dest/linux-$LINUX_VERSION.tar.xz"
fetch "https://musl.libc.org/releases/musl-$MUSL_VERSION.tar.gz" "$dest/musl-$MUSL_VERSION.tar.gz"
fetch "https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2" "$dest/busybox-$BUSYBOX_VERSION.tar.bz2"
