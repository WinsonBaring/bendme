# Progress

## 2026-09-12 [Issue #10]
- Archived implementation and local review history in archive/progress_2026-09-12.md. Current light-theme/sidebar implementation is verified locally; user manually rebuilds. Releases remain paused.

## 2026-09-12 subtle maker credit [Issue #10]
- Added small linked Winson Baring credit in sidebar/About and GitHub, website and issue links in About. Moved About link row above large preview after layout review so it is visible without scrolling.
- Build passed with warnings-as-errors; final About view compiled/rendered and placement reviewed. Four destinations returned HTTP 200. No installed-app or release changes.

## 2026-09-12 subtle profile icon [Issue #10]
- Replaced visible name with Made by + small gray GitHub mark in sidebar/About; Developer profile tooltip and accessible link label. Existing profile destination retained.
- Bundled official transparent favicon; updated SwiftPM/Xcode resource handling and third-party notice. Build passed with warnings-as-errors; About fixture compiled/rendered and icon placement reviewed. No install/release/version changes.
