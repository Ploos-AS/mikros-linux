#!/bin/sh
set -eu

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing host tool: $1"; }

apply_fragment() {
    tree=$1
    fragment=$2
    [ -x "$tree/scripts/config" ] || die "missing kernel scripts/config"
    while IFS= read -r line; do
        case "$line" in
            CONFIG_*=y)
                sym=${line%%=*}; "$tree/scripts/config" --file "$tree/.config" --enable "${sym#CONFIG_}" ;;
            CONFIG_*=m)
                sym=${line%%=*}; "$tree/scripts/config" --file "$tree/.config" --module "${sym#CONFIG_}" ;;
            CONFIG_*=*)
                sym=${line%%=*}; val=${line#*=}
                "$tree/scripts/config" --file "$tree/.config" --set-val "${sym#CONFIG_}" "$val" ;;
            "# CONFIG_"*" is not set")
                sym=${line#\# CONFIG_}; sym=${sym% is not set}
                "$tree/scripts/config" --file "$tree/.config" --disable "$sym" ;;
        esac
    done < "$fragment"
}
