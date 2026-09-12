# Progress

## 2026-09-12 [Issue #10]
- Archived implementation and local review history in archive/progress_2026-09-12.md. Current light-theme/sidebar implementation is verified locally; user manually rebuilds. Releases remain paused.

## 2026-09-12 subtle maker credit [Issue #10]
- Added small linked Winson Baring credit in sidebar/About and GitHub, website and issue links in About. Moved About link row above large preview after layout review so it is visible without scrolling.
- Build passed with warnings-as-errors; final About view compiled/rendered and placement reviewed. Four destinations returned HTTP 200. No installed-app or release changes.

## 2026-09-12 subtle profile icon [Issue #10]
- Replaced visible name with Made by + small gray GitHub mark in sidebar/About; Developer profile tooltip and accessible link label. Existing profile destination retained.
- Bundled official transparent favicon; updated SwiftPM/Xcode resource handling and third-party notice. Build passed with warnings-as-errors; About fixture compiled/rendered and icon placement reviewed. No install/release/version changes.

## 2026-09-12 branded header [Issue #10]
- Replaced generic laptop header icon with the unchanged BendMe app logo. Shared brand resource lookup; included logo in SwiftPM/Xcode/fixture resources.
- Image matches existing icon bytes; build passed with warnings-as-errors and eleven fixtures rendered. Reviewed header placement. No installed-app, permission, version or release change.

## 2026-09-12 public repository link [Issue #10]
- Added subtle Source on GitHub beneath sidebar Made by credit; existing developer profile destination preserved. Updated source README and changelog.
- Build passed with warnings-as-errors; eleven fixtures rendered and sidebar placement reviewed. No installed-app or release changes.

## 2026-09-12 Start into Appearance [Issue #10]
- Updated Try BendMe Start action to navigate through existing showSetup state after startup begins. Kept immediate failure recovery and Pause/Cancel behavior.
- Build passed with warnings-as-errors and diff check passed. Reviewed existing page binding and shared error banner; no live app launch, install or release.

## 2026-09-12 release 0.1.5 [Issue #10 / #11]
- User resumed direct notarization and website publication. Updated visible pause guidance and setup copy; bumped release to 0.1.5/build 6. Tracked un-reproduced shortcut failure in #11.
- Swift 17 tests and website lint/3 tests/build passed. Apple accepted isolated archive; exported app passed strict signature, ticket and Gatekeeper checks. Signed-app GPU self-test passed with 15 renders. Packaging/public verification underway.
- Published v0.1.5 after mounted-DMG verification; public DMG/ZIP/two checksum files match local hashes. Pushed source and deployed Pages (run 34673091473); live HTTP 200 confirms new version and visible pause instructions, with old global promise absent.

## 2026-09-12 local social kit [Issue #12]
- Prepared five platform drafts, tracker, source review, selected stills and compatible video exports locally. Preserved Bendy inspiration credit and avoided unverified claims.
- Validated five caption/media mappings, decoded both videos, confirmed social-media is ignored with no tracked files. No posting or scheduling.

## Standalone portfolio
- Added /portfolio/ ignore rule to keep the separately versioned personal portfolio out of BendMe. Implementation and deployment tracked in the child repository.
