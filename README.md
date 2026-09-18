# RottenLimb

[![Build blocker](https://github.com/Gurkirat-Singh-bit/RottenLimb/actions/workflows/build.yml/badge.svg)](https://github.com/Gurkirat-Singh-bit/RottenLimb/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

RottenLimb builds a deliberately inert Android package that reserves Instagram's
official application ID, `com.instagram.android`. Android permits only one
installed package with an application ID and requires compatible signing
certificates for updates. The reservation uses a different certificate, so the
official Instagram APK should be rejected as an incompatible update while the
reservation remains present.

> [!WARNING]
> This is an experimental personal tool, not an unbreakable security control.
> The standalone APK works without root but can be uninstalled normally. The
> optional Magisk version requires an already-rooted phone and is harder to
> remove. Do not root a phone just because this project exists without first
> understanding the security, compatibility, update, and recovery risks.

## What is inside

The final APK contains:

- the application ID `com.instagram.android`;
- the visible system-list label **Package Reservation**;
- a minimal manifest with `hasCode=false`.

It contains no DEX bytecode, native code, permissions, activities, services,
receivers, providers, launcher icon, network access, storage access, analytics,
telemetry, background process, or interface. CI inspects the final signed APK
and refuses to publish it if these invariants change.

The Magisk ZIP contains only `module.prop` and that verified APK. It has no boot
scripts, daemon, Zygisk library, SELinux rules, or system-property changes.

## What it does not block

- Instagram in a browser
- Instagram Lite or a client with another package name
- use on another phone or Android profile
- a root user removing the Magisk module
- recovery, factory reset, bootloader unlocking, or firmware reflashing
- future Android/OEM behavior that has not been tested on your device

If Instagram is preinstalled as an OEM system app, stop: replacing that case is
not tested by this project.

## AI-authorship disclosure

This repository is **mostly AI-written** with OpenAI Codex, including the initial
implementation, build workflow, documentation, and security audit. AI-generated
code can be incomplete or confidently wrong. CI verification and human review
are still required; this disclosure is not a security guarantee. See the full
[security audit](docs/SECURITY_AUDIT.md).

## Prerequisites

- **No-root install:** Android 8.0 or newer and permission to install the APK
  from your chosen file manager or browser
- **Optional Magisk install:** a phone that is already rooted with a compatible
  Magisk installation, plus a current backup and tested recovery path
- Optional: ADB for stronger verification and USB transfer

This project does not provide rooting instructions.

## Build or download

Open **Actions → Build blocker → Run workflow**. When the run succeeds, download
the `instagram-package-reservation-<run number>` artifact. GitHub downloads an
outer ZIP containing:

```text
instagram-package-reservation.apk
instagram-package-reservation-magisk.zip
SHA256SUMS.txt
```

Extract the outer GitHub artifact ZIP. Do **not** extract the inner Magisk ZIP.
Each workflow run uses a fresh one-off signing key, so keep the exact artifact
you install; builds from different runs cannot update each other.

You can also open the project in Android Studio with Android SDK 36. Local
release builds must be signed with your own protected key.

## Install on the phone

### 1. Back up and remove Instagram

On the phone, open **Settings → Apps → Instagram → Uninstall**. Repeat this in
every work profile, private space, secondary user, or cloned-app area.

With ADB, verify that the package is gone:

```sh
adb shell pm path com.instagram.android
```

The expected result is an error or no package path. If the command returns a
`/system`, `/product`, or `/system_ext` path, Instagram is preinstalled as a
system app; do not continue with this untested configuration.

### 2. Choose one installation method

#### Option A — Standalone APK, no root

This is the normal-phone option. Transfer
`instagram-package-reservation.apk` by USB, Quick Share, or another trusted
method. With ADB:

```sh
adb push instagram-package-reservation.apk /sdcard/Download/
```

On the phone, open the APK from **Files → Downloads**. If Android asks, allow
**Install unknown apps** for that file-opening app, complete the installation,
and turn that permission off again afterward. The placeholder has no launcher
icon or screen; it appears only in Settings' app list as **Package Reservation**.

While this APK remains installed, an Instagram APK signed by Meta should fail
as an incompatible update. You can still remove the placeholder through
**Settings → Apps → Package Reservation → Uninstall**.

#### Option B — Magisk module, root required

Use this only if the phone is already rooted and you want removal to require
opening Magisk rather than the ordinary Android uninstall screen.

Transfer `instagram-package-reservation-magisk.zip` by USB, Quick Share, another
trusted method, or ADB:

```sh
adb push instagram-package-reservation-magisk.zip /sdcard/Download/
```

Transfer the inner `instagram-package-reservation-magisk.zip`, not the GitHub
artifact wrapper. Do not extract the inner ZIP.

Then install it from Magisk's **Modules** screen:

1. Open **Magisk**.
2. Open **Modules**.
3. Choose **Install from storage**.
4. Select `instagram-package-reservation-magisk.zip`.
5. Read the installation output and confirm it finishes without an error.
6. Reboot when Magisk asks.

### 3. Verify

```sh
adb shell pm path com.instagram.android
adb shell dumpsys package com.instagram.android | grep -E 'codePath|versionName'
```

For the standalone install, the code path should be under `/data/app`. For the
Magisk install after reboot, it should resolve through the system overlay. The
reservation has no launcher icon or screen. An attempt to install Meta's APK
should fail with a signature/package conflict.

## Remove or upgrade RottenLimb

For the standalone APK, open **Settings → Apps → Package Reservation →
Uninstall**. For the rooted version, open **Magisk → Modules**, remove
**Instagram Package Reservation**, and reboot. Verify that
`adb shell pm path com.instagram.android` no longer finds the reservation before
installing Instagram.

Because every CI run has a different signing certificate, changing to a newer
artifact requires removing the old placeholder first. The Magisk method also
requires the removal and installation reboots described above.

If the phone fails to boot, use Magisk's documented module-disable/recovery
procedure for your exact Magisk and device version. Do not experiment with
destructive recovery commands without a verified backup.

## Developer verification

```sh
./tools/verify-source.sh

APKSIGNER=/path/to/apksigner \
APKANALYZER=/path/to/apkanalyzer \
  ./tools/verify-apk.sh /path/to/reservation.apk

./tools/verify-module.sh \
  /path/to/instagram-package-reservation-magisk.zip \
  /path/to/reservation.apk
```

Read [SECURITY.md](SECURITY.md) before reporting a vulnerability. Licensed under
the [MIT License](LICENSE).
