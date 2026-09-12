# Current state — local development only

Issue #10: removed automatic System Settings navigation after ScreenCaptureKit consent request. If access remains unavailable, only needsScreenSettings state changes; the user chooses Apple's Open System Settings button or the app's manual button. Denial no longer triggers an app-initiated redirect. Native permission dialog remains owned by macOS.

All 17 tests passed with warnings-as-errors, compiling the current source. User's installed app and privacy state are untouched; no app bundle rebuild/install/launch performed. User should quit their current app and run the manual build/open commands in SETUP.md to try this change. Live OS consent was not automated.

Releases remain paused: no version bumps, Apple submissions/notarization, tags, public releases or website deployment until explicitly resumed. Commit locally only. Issue #10 tracks ongoing review; #5 retains protected empty diagnostic metadata; #2 App Store remains separate. Release/archive packages and source are preserved.
