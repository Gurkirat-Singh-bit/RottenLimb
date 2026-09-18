# Instagram Package Reservation

A code-free Android package that occupies `com.instagram.android`. Because it
is signed with a different key from Meta's APK, Android rejects the official
Instagram app as an incompatible update while this package exists.

The APK has no activities, icon, permissions, services, receivers, providers,
network access, or executable code. It only appears in system package listings
as **Package Reservation**.

## Important limits

- A normal APK can be uninstalled. The included Magisk packaging mounts it as
  a system app, but anyone retaining root and Magisk control can remove the
  module.
- This blocks `com.instagram.android`, not Instagram's website or differently
  named clients.
- Installing the Magisk module changes the phone's boot-time system overlay.
  Keep a tested recovery path and a current backup.

## Build the APK

Open this directory in Android Studio, let it install Android SDK 36 if needed,
and build a signed release APK with **Build > Generate Signed App Bundle or APK**.
Do not commit the signing keystore; `*.jks` and `*.keystore` are ignored.

Alternatively, open the repository's **Actions** tab, select **Build blocker**,
choose **Run workflow**, and download the resulting artifact. It contains both
the signed APK and installable Magisk ZIP. CI uses a fresh one-off signing key
for each run, so keep the artifact you install; a later workflow run is not an
in-place update for an earlier one.

Before using the result, confirm its identity:

```sh
apkanalyzer manifest application-id app-release.apk
apksigner verify --print-certs app-release.apk
```

The first command must print `com.instagram.android`.

## Create the Magisk module

The phone must already use Magisk. Package the signed APK:

```sh
./tools/package-magisk.sh /path/to/app-release.apk
```

This creates:

```text
dist/instagram-package-reservation-magisk.zip
```

Before installation, uninstall every existing Instagram package for every
Android user/profile. Then install the ZIP from the Magisk app and reboot.

Verify after reboot:

```sh
adb shell pm path com.instagram.android
adb shell dumpsys package com.instagram.android | grep -E 'codePath|versionName'
```

`codePath` should point to a system path rather than `/data/app`. Attempting to
install Meta's APK should then fail with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
or an equivalent signature-conflict message.

## Source check

```sh
./tools/verify-source.sh
```
