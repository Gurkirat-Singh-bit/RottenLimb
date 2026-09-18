#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
manifest="$project_dir/app/src/main/AndroidManifest.xml"
build_file="$project_dir/app/build.gradle.kts"

grep -q 'applicationId = "com.instagram.android"' "$build_file"
grep -q 'enableKotlin = false' "$build_file"
grep -q 'android:hasCode="false"' "$manifest"

if grep -Eq '<(activity|activity-alias|service|receiver|provider)|uses-permission' "$manifest"; then
    echo "manifest must remain code-free and permission-free" >&2
    exit 1
fi

if find "$project_dir/app/src/main" -type f ! -name AndroidManifest.xml -print -quit | grep -q .; then
    echo "app source must contain only AndroidManifest.xml" >&2
    exit 1
fi

echo "source invariant check passed"
