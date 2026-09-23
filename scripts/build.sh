#!/bin/sh
set -eu

cmd=${1:-}
target=${2:-x86-i586}
profile=${3:-minimal}
out=${4:-out/$target/$profile}

target_file="targets/$target.conf"
profile_file="profiles/$profile.conf"

[ -f "$target_file" ] || { echo "unknown target: $target" >&2; exit 2; }
[ -f "$profile_file" ] || { echo "unknown profile: $profile" >&2; exit 2; }

# shellcheck disable=SC1090
. "$target_file"
# shellcheck disable=SC1090
. "$profile_file"

case "$cmd" in
  info)
    printf 'MikrOS Linux\ntarget=%s\nprofile=%s\narch=%s\ncpu=%s\nlibc=%s\n' \
      "$target" "$profile" "$MIKROS_ARCH" "$MIKROS_CPU" "$MIKROS_LIBC"
    ;;
  prepare)
    mkdir -p "$out/meta" "$out/rootfs"
    {
      echo "target=$target"
      echo "profile=$profile"
      echo "arch=$MIKROS_ARCH"
      echo "cpu=$MIKROS_CPU"
      echo "libc=$MIKROS_LIBC"
    } > "$out/meta/build.conf"
    ;;
  rootfs)
    mkdir -p "$out/rootfs"/bin "$out/rootfs"/dev "$out/rootfs"/etc/init.d \
      "$out/rootfs"/etc/mikros "$out/rootfs"/proc "$out/rootfs"/root \
      "$out/rootfs"/run "$out/rootfs"/sys "$out/rootfs"/tmp \
      "$out/rootfs"/usr/bin "$out/rootfs"/usr/lib "$out/rootfs"/usr/sbin \
      "$out/rootfs"/var/lib "$out/rootfs"/var/log "$out/rootfs"/var/run
    printf '%s\n' "MikrOS Linux" > "$out/rootfs/etc/mikros/release"
    ;;
  image)
    echo "M0 scaffold: image generation for $target/$profile is not implemented yet."
    echo "Rootfs staging tree: $out/rootfs"
    ;;
  *)
    echo "usage: $0 {info|prepare|rootfs|image} TARGET PROFILE OUT" >&2
    exit 2
    ;;
esac
