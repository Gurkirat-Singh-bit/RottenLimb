#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
manifest="$project_dir/app/src/main/AndroidManifest.xml"
build_file="$project_dir/app/build.gradle.kts"
module_properties="$project_dir/magisk/module.prop"

grep -q 'applicationId = "com.instagram.android"' "$build_file"
grep -q 'enableKotlin = false' "$build_file"
grep -q 'android:hasCode="false"' "$manifest"

app_version=$(sed -n 's/^[[:space:]]*versionName = "\([^"]*\)"/\1/p' "$build_file")
module_version=$(sed -n 's/^version=//p' "$module_properties")
if [ -z "$app_version" ] || [ "$app_version" != "$module_version" ]; then
    echo "APK and Magisk versions must match" >&2
    exit 1
fi

if grep -Eq '<(activity|activity-alias|service|receiver|provider)|uses-permission' "$manifest"; then
    echo "manifest must remain code-free and permission-free" >&2
    exit 1
fi

if find "$project_dir/app/src/main" -type f ! -name AndroidManifest.xml -print -quit | grep -q .; then
    echo "app source must contain only AndroidManifest.xml" >&2
    exit 1
fi

echo "source invariant check passed"
