# Security audit

**Audit date:** 2026-09-18  
**Scope:** Android source, final APK, Magisk archive, build workflow, installation
and removal model  
**Auditor:** OpenAI Codex (AI-generated analysis; not an independent professional
penetration test)

## Executive summary

The intended APK has no permissions, components, native libraries, DEX bytecode,
network capability, storage behavior, or runtime entry point. Its only function
is to reserve the Android application ID `com.instagram.android` with a signing
certificate that differs from Meta's certificate. Android should reject Meta's
APK as an incompatible update while the reservation remains installed.

The project does **not** provide an unbreakable control. A user retaining root,
Magisk access, recovery access, or the ability to reflash the phone can remove
it. It does not block Instagram websites, Instagram Lite, renamed clients,
another device, or every OEM-specific installation path.

No high-severity vulnerability was found in the project's own runtime because
the corrected artifact has no runtime code. The largest risks arise from rooting
the phone, trusting build artifacts, physical device differences, and overstating
the module's resistance to removal.

## Method

- Reviewed every tracked source and workflow file.
- Inspected the built APK and Magisk ZIP contents.
- Verified the APK signing block and exact application ID in CI.
- Checked the merged manifest for permissions, exported/runtime components,
  `debuggable=true`, and `hasCode=false`.
- Checked for DEX files and native libraries.
- Checked that the Magisk ZIP contains only `module.prop` and the verified APK.
- Threat-modeled ordinary Android users, root users, compromised CI dependencies,
  malicious replacement artifacts, recovery access, and alternate Instagram
  clients.

Dynamic testing on the owner's actual phone is still required. This audit does
not cover Magisk itself, the device kernel, bootloader, recovery, OEM firmware,
GitHub's infrastructure, or Android vulnerabilities.

## Findings

### AUD-001 — Unused executable payload in the original APK

- **Severity:** Low
- **Status:** Fixed
- **Cause:** Android Gradle Plugin 9 enabled built-in Kotlin by default and
  packaged Kotlin runtime bytecode even though the project had no source code.
- **Impact:** The manifest's `hasCode=false` prevented normal application-code
  loading, but the README's “no executable code” claim was inaccurate and the
  unused DEX unnecessarily enlarged the artifact and review surface.
- **Fix:** `enableKotlin = false`; CI now rejects any `classes*.dex` or `lib/`
  entry in the final APK.

### AUD-002 — Mutable GitHub Action references

- **Severity:** Medium
- **Status:** Fixed
- **Cause:** Actions used moving major-version tags.
- **Impact:** A compromised or unexpectedly changed upstream tag could alter the
  build running with repository permissions.
- **Fix:** Every third-party action is pinned to a full Git commit SHA. Repository
  permissions remain read-only.

### AUD-003 — Build credential looked reusable

- **Severity:** Informational
- **Status:** Fixed
- **Cause:** The ephemeral keystore used a hard-coded password in workflow text.
- **Impact:** The keystore was destroyed after each run, so this did not expose a
  persistent signing secret; however, it encouraged incorrect assumptions.
- **Fix:** CI generates a random password for the one-off keystore.

### AUD-004 — Each CI run uses a different signing identity

- **Severity:** Low
- **Status:** Accepted and documented
- **Impact:** A later artifact cannot update an earlier artifact. Switching builds
  may require removing the old module/package, rebooting, and installing the new
  artifact. Conversely, destroying the private key prevents future same-key APKs
  from being produced by this workflow.
- **Recommendation:** Keep the exact artifact and checksum you install. Use a
  locally protected persistent signing key only if repeatable updates become a
  real requirement.

### AUD-005 — Root user can remove the control

- **Severity:** Medium for the self-control goal; not a code vulnerability
- **Status:** Accepted limitation
- **Impact:** Magisk's module screen, recovery, root shell, safe-mode behavior, or
  reflashing can remove/bypass the package reservation. A factory reset generally
  removes systemless modules stored under `/data`.
- **Recommendation:** Treat the module as friction, not an authorization boundary.
  Do not claim it is permanent or unremovable.

### AUD-006 — Rooting broadens the phone's security exposure

- **Severity:** Medium; environmental
- **Status:** Accepted prerequisite
- **Impact:** Root/unlocked boot state can weaken platform integrity guarantees,
  affect banking/DRM applications and updates, and increase the consequence of a
  malicious root module. This project does not root the phone, but its Magisk
  delivery assumes that risk already exists.
- **Recommendation:** Review the ZIP before installation, keep backups and a known
  recovery path, and do not root a phone solely for this project without accepting
  those tradeoffs.

### AUD-007 — Scope gaps

- **Severity:** Medium for the behavioral goal; not a code vulnerability
- **Status:** Accepted limitation
- **Impact:** The package only reserves `com.instagram.android`. It does not block
  `instagram.com`, Instagram Lite, repackaged clients, other profiles/devices, or
  future package-name changes.
- **Recommendation:** State the scope explicitly and test every Android profile.

### AUD-008 — Device/OEM compatibility remains unverified

- **Severity:** Low
- **Status:** Open
- **Impact:** Package scan timing, preinstalled Instagram variants, Magisk behavior,
  Android developer verification, and OEM modifications may change results. If
  Instagram is already a system app, this module is not a tested replacement.
- **Recommendation:** Test on the exact device with a recoverable backup. Confirm
  the system code path and signature-conflict behavior before relying on it.

## Properties not present

- No requested Android permissions.
- No exported or non-exported activities, services, receivers, or providers.
- No launcher icon or interactive UI.
- No network client, domain, analytics, advertising, telemetry, or updater.
- No credential, identifier, account, file, database, preference, or log access.
- No native libraries, dynamic loading, reflection, WebView, JavaScript, or DEX.
- No boot script, daemon, Zygisk library, SELinux policy, or property modification
  in the Magisk module.
- No committed keystore, private signing key, access token, or device secret.

## Residual-risk conclusion

After the fixes above, the project is intentionally tiny and auditable. Its
privacy risk is negligible because it cannot run or access data. Its meaningful
risks are operational: installing an untrusted root module, losing recovery
access, relying on an untested OEM implementation, and believing the reservation
is stronger or broader than it is.

