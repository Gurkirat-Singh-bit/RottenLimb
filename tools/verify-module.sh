#!/bin/sh
set -eu

if [ "$#" -ne 2 ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "usage: $0 /path/to/module.zip /path/to/reservation.apk" >&2
    exit 2
fi

module=$1
apk=$2
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

entries=$(unzip -Z1 "$module" | grep -v '/$' | sort)
expected='module.prop
system/app/InstagramPackageReservation/InstagramPackageReservation.apk'

if [ "$entries" != "$expected" ]; then
    echo "Magisk archive contains unexpected files" >&2
    printf '%s\n' "$entries" >&2
    exit 1
fi

unzip -p "$module" module.prop | grep -q '^id=instagram_package_reservation$'
unzip -p "$module" system/app/InstagramPackageReservation/InstagramPackageReservation.apk > "$tmp_dir/embedded.apk"
cmp -s "$apk" "$tmp_dir/embedded.apk"

echo "Magisk module invariant check passed"

