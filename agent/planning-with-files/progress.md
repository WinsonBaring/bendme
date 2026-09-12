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

## 2026-09-12 fresh-install cleanup [Issue #5]
- Confirmed notarization finisher completed and published approved artifacts; fast-forwarded local main to the release commits.
- Stopped two BendMe processes, including a translocated downloaded copy, and ejected all three mounted BendMe installers.
- Reset all BendMe-only privacy grants for public, development and diagnostic bundle identifiers; cleared defaults and unregistered local build copies from Launch Services.
- Removed /Applications/BendMe.app and dist/BendMe.app while preserving source and release artifacts.
- Two diagnostic sandbox containers have protected macOS metadata; Finder removal is pending local OS approval. Main app and preferences are already absent.
- Removed both diagnostic Data directories; only the protected container metadata remains. Finder deletion timed out. Full diagnostic-container removal remains unresolved, but installed app, processes, preferences, permissions and mounted installers are absent.

## 2026-09-12 Dock application [Issue #6]
- Normal app activation is regular; both packaging paths set LSUIElement=false. Settings reopening restores minimization; menu-bar controls remain. Version 0.1.1/build 2.
- Eight native tests and website checks passed. Initial window probe ran before launch completed; subsequent runtime checks confirmed regular activation and one visible settings window. Reopening existing app retained one visible window. Hidden/minimized automation was unavailable; minimization restoration is implemented but not separately UI-automated.
- Apple accepted the separate 0.1.1 archive; signature, ticket, Gatekeeper and mounted DMG checks passed. Replaced /Applications/BendMe-2.app with approved /Applications/BendMe.app and launched it, preserving settings and permissions. Public release publication follows.
- Published v0.1.1 DMG/ZIP/checksums and verified public hashes. Pages deployment succeeded; live HTML contains the 0.1.1 download and Dock feature copy. Installed app reports regular activation, one visible settings window and hidden=false.
- Remote Checks run 34667657103 passed. Issue #6 complete; committed and pushed final verification state.

## 2026-09-12 interactive setup [Issue #7]
- Added live installation/permission/effect stages, actual Finder/settings/reopen buttons, floating visual permission companion and persisted setup recovery. No Accessibility permission needed.
- Added nine setup tests (17 total) and eight isolated native layout fixtures; all passed and layouts reviewed. Adjusted companion background and compact content after inspection. Website checks passed.
- Version 0.1.2/build 3 accepted by Apple; app signature, stapled ticket and Gatekeeper passed. Packaged DMG/ZIP. Installation identity guard caught the known local preview copy; explicitly replaced that copy with the approved public app, preserving public preferences. Runtime verified regular Dock activation and one visible settings window.
- Publishing verified downloads and website follows. OS consent and a complete physical-lid walkthrough remain manual acceptance checks.
- Published v0.1.2 and verified all four public artifact hashes. Pages run 34669038165 passed; live HTML contains the new DMG URL and interactive Setup guidance.
- GitHub Checks run 34669038183 passed: native tests, unsigned App Store archive, website checks and dependency audit. Issue #7 is complete.

## 2026-09-12 repeat fresh-install cleanup [Issue #5]
- User requested removal after guided-setup delivery. Stopped BendMe, removed installed app and three local development bundles; preserved source and release/archive artifacts. No BendMe installer volume was mounted.
- Deleted public/setup-preview defaults. Initial privacy reset after unregistering could not resolve the app; temporarily registered the preserved approved public app, successfully reset all public approvals, then unregistered it. Diagnostic identity reset attempts still returned no-such-identifier; no successful reset claimed for them.
- Verified no running process, no BendMe app in Applications/Downloads/Desktop, and no public/setup-preview defaults. Two protected empty diagnostic metadata folders remain with no Data directories. Latest DMG preserved; leave app uninstalled for manual testing.

## 2026-09-12 missing permission row [Issue #8]
- User's screenshot confirms no BendMe row in upper screen recording list. Added async ScreenCaptureKit consent request with duplicate-request guard and prominent missing-app instructions, illustrated upper +, actual app-path copy action, switch/reopen steps. No capture stream starts and no consent is bypassed.
- Seventeen native tests passed. Added missing-app and requesting layout fixtures; reviewed main and companion and shortened missing-app copy after a clipping check. Preserve user's installed app and privacy state during release preparation.
- Apple accepted 0.1.3/build 4; signature, stapled ticket, Gatekeeper and mounted DMG passed. Published v0.1.3 and verified all four public asset hashes. No installed app or user permission state changed.
- Pages run 34669618518 passed; live HTML contains the v0.1.3 DMG URL and missing-app guidance.
- GitHub Checks 34669618513 passed (native tests/archive, website checks/audit). Issue #8 implementation and release complete; automatic first-use permission registration remains unverified.

## 2026-09-12 simple native consent [Issue #9]
- User rejected the extra floating guide and lengthy instructions. Removed companion window, imitation switch/plus examples, missing-app helper and clipboard state.
- Kept native ScreenCaptureKit consent and actual permission polling. Primary button becomes Open System Settings only if access remains unavailable; short reopen action appears conditionally. No Accessibility or custom permission bypass.
- Removed a leftover companion reference identified by compilation; final 17 tests and website checks passed. Eight layouts rendered and minimal permission/recovery views reviewed. Submitted separate 0.1.4/build 5 archive for Apple notarization.
- Apple accepted 0.1.4/build 5; signature, ticket, Gatekeeper and mounted DMG passed. Published v0.1.4; release and website verification in progress. User installation was not changed.
- Verified all public artifact hashes and live v0.1.4 download/short consent copy. Pages run 34669954828 passed.
- GitHub Checks 34669954841 passed (native tests/archive and website checks/audit). Issue #9 implementation/release complete; real first-use consent remains manual acceptance.

## 2026-09-12 local review pause
- User paused upgrades and Apple/public releases to review the app first. Confirmed no notarization/submission worker is running. Displayed the current app-owned setup fixture; preserving installation and permissions.
- [Issue #10] Rendered current Appearance layout using a temporary isolated harness in dist/UIReview. Bitmap rendering omits Metal surfaces, so preview areas are black in this snapshot; do not report an app rendering failure. No product code, version, installation or permission state changed.
