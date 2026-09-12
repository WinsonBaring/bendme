# Changelog

## Unreleased

- Recorded local uninstall and permission reset for a fresh manual test of the notarized DMG; source and release artifacts are preserved.

- Published Developer ID signed, Apple-notarized app downloads with attached approval tickets; replaced the earlier unsigned preview packages.

- Added Xcode-managed Developer ID upload/export and notarization verification for direct distribution; packaging refuses to claim notarization without a valid app ticket and Gatekeeper acceptance.

- Added a verified DMG download with Applications shortcut and installation notes; website now downloads the DMG from GitHub Releases.

- Publish a free MIT-licensed development preview and maker landing page for Winson Baring, with GitHub Pages automation.
- Add downloadable arm64 app packaging and SHA-256 checksums without replacing the working local app.
- Add native Xcode archive target, sandbox entitlements, privacy manifest, icon catalog and draft App Store metadata. App Store submission remains pending distribution credentials and account details.


- Document and verify recovery from stale Screen Recording authorization; enable the local app and confirm live desktop capture through LaunchServices.

- Add native macOS menu-bar BendMe app with live lid-angle tracking and a manual preview.
- Add Metal desktop perspective, variable blur, shadow, and Silk/Shade/Frost styles.
- Add ScreenCaptureKit capture, built-in display selection, overlay exclusion, permission controls, pause shortcuts, sleep/display lifecycle handling, and persistent appearance settings.
- Add original procedural preview artwork, hardware diagnostics, GPU render verification, unit tests, and locally signed app packaging.
