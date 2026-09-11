# BendMe implementation

GitHub issue: unavailable — repository has no remote and no GitHub MCP is exposed.
Local scope below is the issue draft; do not invent a remote issue number.

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
- [ ] GitHub issue/remote delivery (blocked: no remote or GitHub MCP).
