# RottenLimb

[![Build](https://github.com/Gurkirat-Singh-bit/RottenLimb/actions/workflows/build.yml/badge.svg)](https://github.com/Gurkirat-Singh-bit/RottenLimb/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/Gurkirat-Singh-bit/RottenLimb)](https://github.com/Gurkirat-Singh-bit/RottenLimb/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Instagram can eat an absurd amount of time. “Just use some willpower” is not
very useful once opening it has become automatic, so this little weekend project
puts something physical in the way.

RottenLimb installs an empty Android package in Instagram's package slot. There
is no feed, login, launcher icon, background service, or screen to open. Install
it once and forget it.

> [!IMPORTANT]
> This repository is **mostly AI-generated with OpenAI Codex**, under human
> direction. That includes most of the implementation, shell tooling, workflows,
> documentation, and security audit. AI-written does not mean reviewed or safe by
> default; the small final artifact and automated checks are what make inspection
> practical.

## Download

Get the current files from [GitHub Releases](https://github.com/Gurkirat-Singh-bit/RottenLimb/releases/latest):

- [Download the APK directly](https://github.com/Gurkirat-Singh-bit/RottenLimb/releases/latest/download/instagram-package-reservation.apk)
- `instagram-package-reservation-magisk.zip` for an already-rooted phone
- `SHA256SUMS.txt` to verify either download

The APK is attached directly to each release. You do not need to unpack a
GitHub Actions artifact. GitHub also adds the source-code ZIP and tarball to
every release automatically.

## Install without root

Requires Android 8.0 or newer.

1. Uninstall Instagram.
2. Check every work profile, Private Space, Second Space, XSpace, secondary
   user, and cloned-app area. Android will reject RottenLimb if Meta's package
   remains installed in any of them.
3. Download `instagram-package-reservation.apk` from Releases and send it to the
   phone with USB, Quick Share, or another method you trust.
4. Open the APK. If Android asks, temporarily allow **Install unknown apps** for
   the file manager or browser you used.
5. Install it, then turn that permission back off.

Nothing opens afterward. The package appears in **Settings → Apps** as
**Package Reservation**, and Play Store should no longer be able to install the
real Instagram package over it.

The no-root APK is still a normal user app, so Android can uninstall it. This
version adds a speed bump; it does not replace every bit of willpower.

Optional ADB checks:

```sh
adb shell pm path com.instagram.android
adb shell dumpsys package com.instagram.android | grep -E 'codePath|versionName'
```

A no-root installation normally has a `/data/app` code path.

## Stronger installation with Magisk

If your phone is **already rooted**, the Magisk build is the recommended
RottenLimb installation. It places the same verified APK in a system overlay,
removing the ordinary one-tap app uninstall path.

Rooting a phone solely for this project is not a casual recommendation. An
unlocked bootloader and root can affect device integrity, banking and DRM apps,
updates, and recovery. Back up the phone and understand its recovery procedure
first.

1. Uninstall Instagram and the standalone RottenLimb APK.
2. Download `instagram-package-reservation-magisk.zip`. Do not extract it.
3. Open **Magisk → Modules → Install from storage** and select the ZIP.
4. Reboot.
5. Run `adb shell pm path com.instagram.android` if you want to verify that the
   package resolves through the system overlay rather than `/data/app`.

This is stronger friction, not an unbreakable lock. Someone with Magisk, root,
recovery, or firmware access still controls the phone.

## How it works

Android identifies Instagram by the unique application ID
`com.instagram.android`. Only one package with that ID can be installed for the
device, and an update must have a compatible signing certificate.

RottenLimb claims that ID using its own certificate. While it remains installed,
Meta's differently signed APK is treated as an incompatible update and rejected.
There is no reverse engineering of Instagram and no Meta code in this project.

The final APK has:

- the package ID `com.instagram.android`;
- a minimal manifest with `hasCode=false`;
- no permissions, activities, services, receivers, or providers;
- no DEX bytecode or native libraries;
- no network, storage, analytics, telemetry, or updater.

Most of this repository is short shell verification/packaging code, GitHub
Actions YAML, and documentation. The APK itself has no runtime program. CI
inspects the final signed file and refuses to publish it if those properties
change. Read the [full security audit](docs/SECURITY_AUDIT.md) for the checks,
fixed findings, and remaining risks.

## What it does not cover

- Instagram in a web browser
- Instagram Lite, repackaged clients, or a future different package ID
- another phone or Android profile
- an OEM image where Instagram is preinstalled as a system app
- factory reset, recovery, bootloader, root, or firmware-level removal

## Building and releasing

Run the source-only checks locally:

```sh
./tools/verify-source.sh
```

GitHub Actions builds, signs with a fresh one-off key, audits the final APK,
packages the Magisk module, and publishes checksums. Because each build has a
new signing certificate, keep the exact file you install; another run cannot
update it in place.

To publish a release, update the version when needed and push a version tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The release workflow reuses the audited build and attaches the APK, Magisk ZIP,
and checksums directly to the GitHub Release. Existing releases are not
overwritten by the workflow.

<details>
<summary>Removal and recovery</summary>

For the standalone APK, use **Settings → Apps → Package Reservation →
Uninstall**.

For the Magisk version, remove **Instagram Package Reservation** from Magisk's
Modules screen and reboot. If the phone cannot boot, follow the recovery/module
disable procedure for your exact Magisk and device version. Verify that
`adb shell pm path com.instagram.android` returns nothing before installing
Instagram or a different RottenLimb build.

</details>

## License and security

MIT licensed: inspect it, fork it, change it, or reuse it. See [LICENSE](LICENSE).
Please read [SECURITY.md](SECURITY.md) before reporting a vulnerability.
