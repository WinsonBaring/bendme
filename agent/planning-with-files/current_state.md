# Current state — local development only

Issue #10: app now uses a white/light theme, light-gray sidebar, blue accents, white cards and Aqua native controls/title bar. AppTheme.swift shares colors. All sidebar items use the same full-width selection and subtle keyboard-focus outline. Default/programmatic focus follows the selected page, so Setup does not retain the old label-sized blue focus box while Appearance is selected. Keyboard focusability and selected accessibility traits remain.

Validation: 17 tests passed with warnings-as-errors; after final focus alignment, the native view harness compiled and rendered eleven fixtures. Reviewed Setup and Appearance. Added shader resource to fixture harness so Appearance layout loads normally; bitmap snapshots still omit GPU surfaces. Full manual keyboard interaction and live GPU appearance were not automated. Xcode target regenerated with AppTheme.swift; version unchanged.

User's installed app and permissions are untouched. User manually rebuilds/reopens via SETUP.md. Keep simple onboarding and no automatic Settings redirect. Releases remain paused: no version bumps, Apple submissions/notarization, tags, releases or website deployment until explicitly resumed. Local commits only. #10 ongoing review; #5 protected empty diagnostic metadata; #2 App Store separate.
