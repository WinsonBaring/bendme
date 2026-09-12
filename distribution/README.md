# App Store preparation

This folder holds the native Xcode app's Info.plist, App Sandbox entitlements, original icon catalog, privacy manifest, and draft App Store metadata. It is not evidence of App Store submission or approval.

The source is shared with SwiftPM. `BendMe.xcodeproj` compiles the same Swift files as one native app module; guarded BendCore imports allow both builds. A declared Xcode build phase copies the canonical Metal shader. No second copy of application logic is maintained.

The app requests only App Sandbox and USB device access. A sandboxed diagnostic build successfully read this Mac's sensor at 123°. The UserDefaults privacy reason CA92.1 describes preferences in the app's own container. Elapsed-time use for animation and capture timing is declared under 35F9.1. No tracking or collected data is declared because the app has no network or telemetry path.

See [SETUP.md](SETUP.md) for archive commands and the exact remaining submission requirements.

Direct preview packaging produces a DMG with an Applications shortcut and installation notes, plus a ZIP alternative. Both contain the same app; neither format changes signing or notarization status.

Direct GitHub notarization is separate from App Store submission. See the direct-distribution workflow in [SETUP.md](SETUP.md); it supports Xcode-managed Developer ID signing and validates Apple's accepted artifact before packaging.

Direct distribution notarization completed through the configured paid Xcode team. Ticket, Gatekeeper, mounted DMG and public download checks passed. App Store submission is separate.

Version 0.1.3 uses a regular Dock application configuration (LSUIElement false), retaining menu-bar controls. Both the Xcode and SwiftPM packaging paths agree.

Version 0.1.3/build 4 adds interactive setup and a floating Screen Recording guide. Direct distribution is Developer ID signed and Apple-notarized; no additional Accessibility permission is requested.
