# Progress

- 2026-09-12: Read README and all images; preserved original brief. Inspected reference site, Apple docs and local HID registry. Located planning skill in another checkout. Established native architecture and delivery plan.

- Implemented native app, core tests, HID reads, Metal renderer, capture and UI. Eight tests passed; hardware read 116 degrees on Apple M3 Pro. Initial GPU tests passed 15 renders with exact open-lid identity. Visual review found sparse blur ghosting; replaced it with MPS Gaussian scale interpolation. Fixed SwiftPM app-resource packaging for strict code signing. Screen Recording is not granted.

- Finalized compact native settings layout, original app icon, standard menus, app-bundle resource resolution without build-directory fallback, and bounded GPU submissions. Added live capture smoke-test command that refuses missing permission.
- Verified 8 tests with warnings as errors, release build, strict signature, 15 GPU renders, manual preview at 26 degrees, real sensor Follow lid at 110 degrees, and persisted Shade selection. All Appearance controls now fit without scrolling.
- Screen Recording confirmation remains pending; General UI independently confirms permission absent. Live capture test exits cleanly with an explicit error. End-to-end physical tests are documented as unverified, not passed.
- Updated setup, architecture, changelog, original reference preservation, GPU evidence, and current state. Preparing final local commit; no remote issue or push is possible.
- Final delivery: locally signed app and ZIP created, latest bundle relaunched, and implementation staged for commit. Only permission-dependent acceptance and unavailable GitHub tracking remain outstanding.

- Activation follow-up: user authorized enabling BendMe. System Settings already showed Screen Recording on, but the current app preflight remained false after toggle/restart. Reset only local.bendme.mac's ScreenCapture record and added the exact current app through the native file chooser; Quit & Reopen restored authorization.
- Enabled app: native UI shows LIVE / Pause BendMe. Turned Follow lid on (112°), retaining Shade and clear angle 100°.
- Live smoke test launched via `open` passed with 3 complete 1512×982 frames and valid overlay exclusion; test stream stopped and original app remained live. No desktop images saved. Direct CLI permission differs due to macOS launch responsibility.
- Updated setup, verification, changelog, findings and state. No app rebuild, no new signature, no changes to other applications' permissions. GitHub remains unavailable.

## 2026-09-12 public release preparation
- Created public WinsonBaring/bendme repository and issues #1/#2 using GitHub CLI after user declined plugins.
- Added MIT release, standalone maker landing page with actual GPU previews, GitHub Pages workflow, isolated desktop packaging, and Xcode App Store configuration.
- Verified eight Swift tests, 15 GPU renders, website lint/three tests/typecheck/prerender, zero npm advisories, strict ad-hoc signature, and unsigned Xcode archive.
- Sandboxed Xcode diagnostic copy read the physical lid sensor. Final signed sandbox capture, physical acceptance, credentials and App Store submission remain pending under #2.

- Published main, v0.1.0 prerelease ZIP/checksum, and GitHub Pages. Live HTML/initial assets HTTP 200; downloaded ZIP byte equality and integrity passed. Remote website/native CI and Pages deployment succeeded. Issue #1 complete; #2 remains open for Apple account and final signed acceptance.

## 2026-09-12 DMG delivery [Issue #3]
- Added repeatable compressed DMG packaging with Applications shortcut, installation notes, strict app-signature verification and dedicated checksum.
- Mounted the DMG read-only, verified its app signature and shortcut, and compared app contents with the existing release ZIP: identical. Ejected cleanly.
- Website lint/tests/typecheck/build passed with the DMG URL and installation copy; retained preview signing disclosures and ZIP alternative.
- Published the DMG and dedicated checksum to v0.1.0. Public download byte comparison and hdiutil verification passed. Live GitHub Pages HTML contains the direct DMG link. Issue #3 complete.

## 2026-09-12 Developer ID notarization [Issue #4]
- User confirmed paid membership and authorized setup. Xcode's configured team is a paid individual team; the local identity inventory alone was incomplete evidence.
- Native UI automation was unavailable (assistive access denied), so used Xcode's supported CLI account/provisioning workflow without plugins or browser tools.
- Development archive succeeded; automatic Developer ID export with destination upload succeeded using Xcode-managed signing. Submitted app has secure timestamp, paid team identifier and hardened runtime.
- Apple reports processing. Added submit/export script and notarized-app packaging guard; approval and public replacement still pending.
- Apple remained processing after repeated checks; added a bounded resumable finisher. Publication mode verifies artifacts, checks remote source consistency, builds and publishes the updated website, validates public hashes/live copy, then records completion. It stops on rejection or any verification failure.

Issue #4 complete: Apple accepted the app; signature, ticket, Gatekeeper, mounted DMG and public checksum checks passed. DMG/ZIP replaced and live Pages copy verified. App Store release remains separate under #2.
