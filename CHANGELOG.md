# Changelog

## Unreleased

- BendMe 0.1.3 requests screen access through ScreenCaptureKit and adds prominent missing-app guidance, the correct + button illustration and installed-app path copying when BendMe is absent from permission settings.

- Removed local BendMe installation and reset public setup/privacy state for manual testing of v0.1.2 onboarding; published downloads and source are preserved.

- BendMe 0.1.2 guides installation and Screen Recording setup inside the app, with working navigation buttons, a floating visual companion, automatic checks, restart recovery and a first-live-effect walkthrough. Manual preview remains available without permission.

- BendMe 0.1.1 now appears in the Dock as a regular desktop application. Opening it restores its settings window, including when minimized; menu-bar controls remain available.

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
