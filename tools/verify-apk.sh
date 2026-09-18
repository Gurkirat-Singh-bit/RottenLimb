#!/bin/sh
set -eu

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
    echo "usage: $0 /path/to/reservation.apk" >&2
    exit 2
fi

: "${APKSIGNER:?set APKSIGNER to the Android SDK apksigner path}"
: "${APKANALYZER:?set APKANALYZER to the Android SDK apkanalyzer path}"

apk=$1
manifest=$("$APKANALYZER" manifest print "$apk")

"$APKSIGNER" verify --verbose --print-certs "$apk"
test "$("$APKANALYZER" manifest application-id "$apk")" = "com.instagram.android"
printf '%s\n' "$manifest" | grep -q 'android:hasCode="false"'

if printf '%s\n' "$manifest" | grep -Eq '<uses-permission|<(activity|activity-alias|service|receiver|provider)([ >])|android:debuggable="true"'; then
    echo "APK contains a permission, executable component, or debug flag" >&2
    exit 1
fi

executable_entries=$(unzip -Z1 "$apk" | grep -E '(^|/)classes[^/]*\.dex$|(^|/)lib/' || true)
if [ -n "$executable_entries" ]; then
    echo "APK contains DEX or native executable code" >&2
    printf '%s\n' "$executable_entries" >&2
    unzip -l "$apk" >&2
    exit 1
fi

echo "APK invariant check passed"
