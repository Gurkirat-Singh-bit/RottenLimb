# Security policy

## Supported version

Only the latest GitHub Release and the current `main` branch are supported. This
is an experimental personal tool, not a security boundary, parental-control
product, or production MDM.

## Reporting a vulnerability

Use the repository's **Security** tab to submit a private vulnerability report.
Do not include device identifiers, account credentials, signing keys, recovery
codes, or other secrets in a public issue.

Include the commit, Android version, root solution and version, device model,
reproduction steps, observed result, and expected result. There is no guaranteed
response time or security-update SLA.

## Artifact trust

Prefer files attached directly to this repository's GitHub Releases. Release
assets are produced by the same audited build as the `Build blocker` workflow;
compare them with `SHA256SUMS.txt`. GitHub Actions generates a new one-off
signing key for each run and destroys it with the runner, so artifacts from
different runs are not update-compatible.
