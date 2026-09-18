#!/bin/sh
set -eu

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
    echo "usage: $0 /path/to/signed-reservation.apk" >&2
    exit 2
fi

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
stage_dir="$project_dir/build/magisk-module"
output="$project_dir/dist/instagram-package-reservation-magisk.zip"

rm -rf "$stage_dir"
mkdir -p "$stage_dir/system/app/InstagramPackageReservation" "$project_dir/dist"
cp "$project_dir/magisk/module.prop" "$stage_dir/module.prop"
cp "$1" "$stage_dir/system/app/InstagramPackageReservation/InstagramPackageReservation.apk"

rm -f "$output"
(cd "$stage_dir" && zip -qr "$output" .)
echo "$output"

