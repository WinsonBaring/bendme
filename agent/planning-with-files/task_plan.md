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
