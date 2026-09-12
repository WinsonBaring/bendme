# App Store preparation

This folder holds the native Xcode app's Info.plist, App Sandbox entitlements, original icon catalog, privacy manifest, and draft App Store metadata. It is not evidence of App Store submission or approval.

The source is shared with SwiftPM. `BendMe.xcodeproj` compiles the same Swift files as one native app module; guarded BendCore imports allow both builds. A declared Xcode build phase copies the canonical Metal shader. No second copy of application logic is maintained.

The app requests only App Sandbox and USB device access. A sandboxed diagnostic build successfully read this Mac's sensor at 123°. The UserDefaults privacy reason CA92.1 describes preferences in the app's own container. Elapsed-time use for animation and capture timing is declared under 35F9.1. No tracking or collected data is declared because the app has no network or telemetry path.

See [SETUP.md](SETUP.md) for archive commands and the exact remaining submission requirements.
