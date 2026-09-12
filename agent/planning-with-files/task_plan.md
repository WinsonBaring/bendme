# BendMe implementation

Tracking: [Issue #1](https://github.com/WinsonBaring/bendme/issues/1) public release and website; [Issue #2](https://github.com/WinsonBaring/bendme/issues/2) App Store. User declined plugins; use authenticated GitHub CLI.

## Phase 1: Research and design
- [x] Read complete brief and four reference images.
- [x] Inspect reference site via HTTP (no browser) and Apple ScreenCaptureKit docs.
- [x] Confirm local HID lid-angle sensor; inspect hardware report descriptor.
- [x] Recover planning skill and preserve original brief.

## Phase 2: Native application
- [x] Implement validated settings, fold geometry, HID sensor, and unit tests.
- [x] Implement ScreenCaptureKit capture excluding overlay windows.
- [x] Implement Metal perspective, progressive blur, and shadow renderer.
- [x] Build native appearance/general/about interface and menu-bar controls.
- [x] Handle permissions, errors, displays, sleep/wake, pause, and cleanup.

## Phase 3: Delivery
- [x] Run tests, GPU self-test, hardware diagnostics, release build, and native UI QA.
- [x] Refresh stale Screen Recording authorization and enable live desktop capture.
- [x] LaunchServices capture smoke test: 3 complete frames at 1512×982, overlay exclusion resolved.
- [ ] Physical lid / sleep / Spaces acceptance beyond live capture.
- [x] Package locally signed .app, launch and verify running process.
- [x] Update docs, changelog, and current state; commit implementation.
- [x] GitHub repository and release issues created through CLI.

## Phase 4: Free public release and maker website
- [x] Create public GitHub repository and release issues using CLI (user explicitly declined plugins).
- [x] Add open-source license, contribution/security guidance, clean release archives and downloadable desktop app.
- [x] Build responsive landing page, interactive effect preview, maker profile, installation and privacy information.
- [x] [Issue #1] Deploy publicly through GitHub Pages and verify website and release downloads.
- [x] Test App Sandbox hardware compatibility and prepare App Store submission assets/configuration.
- [ ] [Issue #2] Submit to App Store when distribution signing, membership, app record, final signed sandbox capture, physical acceptance and screenshots are available.

## Phase 5: [Issue #3] DMG download
- [x] Package the existing verified preview as a compressed DMG with Applications shortcut.
- [x] Verify mounted contents/signature, publish DMG/checksum, and update website/docs.
- [x] Verify deployed download, update issue/state and commit.

## Phase 6: [Issue #4] Developer ID notarization
- [x] Confirm Xcode has a paid individual team configured.
- [x] Obtain Developer ID signing through Xcode-managed signing with the configured paid team.
- [x] Sign with hardened runtime, submit to Apple, staple and assess the accepted artifact.
- [x] Publish only verified notarized downloads and update public disclosures.

## Phase 7: [Issue #5] Fresh-install cleanup
- [x] Stop all BendMe processes and eject three mounted installers.
- [x] Remove installed and local development app bundles, defaults and privacy grants.
- [ ] Remove two remaining protected diagnostic metadata files (macOS denied command-line removal; Finder timed out). All diagnostic app data is removed.
- [x] Record verified cleanup and remaining protected metadata; commit.

## Phase 8: [Issue #6] Dock application behavior
- [x] Use regular activation and matching bundle flags; restore minimized settings on reopen.
- [x] Verify regular Dock activation and visible settings for the built and installed apps; eight native tests passed.
- [x] Publish approved version 0.1.1 with isolated archives; verify public artifacts and live website.

## Phase 9: [Issue #7] Interactive setup guide
- [x] Add installation, permission, first-effect and completion states with actual checks.
- [x] Add settings navigation, a floating visual permission companion and restart recovery.
- [x] Verify state transitions, native layout and failure recovery; document OS consent limits.
- [x] Sign/notarize version 0.1.2, install it, publish downloads and update website guidance.

## Phase 10: [Issue #5] Repeat clean install test for v0.1.2
- [x] Remove installed/development apps and preferences; reset public privacy approvals.
- [x] Verify no running or installed copies; preserve source and release downloads.
- [ ] Remove protected empty diagnostic metadata (macOS denies removal; unrelated to the public app's onboarding).

## Phase 11: [Issue #8] Missing Screen Recording row
- [x] Use ScreenCaptureKit permission request and explicit missing-app branch with upper-list + and copy-path assistance.
- [x] Validate native layouts/tests and publish notarized 0.1.3; preserve the user's manual-test installation.

## Phase 12: [Issue #9] Simple native consent
- [x] Remove floating guide and verbose permission instructions; use one native consent button with short conditional recovery.
- [x] Validate, notarize and publish 0.1.4 without altering the user's installed app or permissions.

## Phase 13: [Issue #10] Local UI review — releases paused
- [x] Show current native setup preview.
- [x] Render the main Appearance layout locally (GPU surfaces are not included in the bitmap snapshot).
- [ ] Iterate locally from user feedback.
- Release gate: no version bump, Apple submission or publishing until explicitly resumed.

## Phase 14: [Issue #5 / #10] Manual development startup
- [x] Remove installed/extracted apps, eject installer, reset public permission and clear preferences.
- [x] Verify no running app and document manual build/open in user Applications.
- [ ] User manually builds and reviews the development app; releases remain paused.

## Phase 15: [Issue #10] Respect native permission dialog
- [x] Remove app-initiated Settings redirect after the request; keep manual Settings action.
- [x] Compile/test locally (17 tests passed), then leave rebuilding/launching the installed development app to the user.

## Phase 16: [Issue #10] Compact post-permission setup
- [x] Simplify first-effect and completion views; show only relevant progress/error recovery.
- [x] Compile and render ten local fixtures; review compact layouts; leave installed-app rebuild/launch to user.

## Phase 17: [Issue #10] Light theme and consistent sidebar
- [x] Share light colors across Setup/Settings and Aqua window; use uniform full-row sidebar focus styling.
- [x] 17 tests passed; compile/render eleven fixtures and inspect Setup/Appearance, including initial focus alignment. Installed app and release pause preserved.

## Phase 18: [Issue #10] Subtle maker credit
- [x] Add small linked developer credit in sidebar/About and project links in About.
- [x] Local build and About layout render passed; links returned HTTP 200. No install or release changes.

## Phase 19: [Issue #10] Icon-only developer identity
- [x] Replace personal name with subtle Made by + GitHub icon linking to profile; accessible Developer profile label and tooltip.
- [x] Bundle official transparent mark, compile and inspect local About/sidebar placement. No install or release.
