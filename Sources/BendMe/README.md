# BendMe application

`BendMeMain.swift` creates the menu bar and settings window. `AppModel.swift` coordinates hardware, permissions, lifecycle, shortcuts, capture, and overlays. `SettingsView.swift` provides Appearance, General and About. `DesktopCapture.swift` owns ScreenCaptureKit. `MetalRenderer.swift` owns texture lifetime and GPU submission. `PreviewArtwork.swift` draws the original landscape. `Diagnostics.swift` implements hardware diagnostics, offscreen GPU tests, and an opt-in live capture smoke test. [Resources](Resources/README.md) contains the shared shader.

Build and launch through [the root setup guide](../../SETUP.md); the app needs its bundled shader resource.

The same files compile in the native Xcode target. Conditional BendCore imports avoid duplicating application logic, and resource lookup supports the Xcode app bundle and SwiftPM CLI.

Normal launches now use regular AppKit activation so the app appears in the Dock. Reopening activates the settings window and restores it from minimization; capture diagnostics remain an accessory process.

`SetupView.swift` provides the first-launch installation guide and floating permission companion. Buttons reveal the app in Finder, open Applications or Screen Recording settings, and reopen the installed app. `AppModel` polls setup facts while the guide is visible and resumes unfinished setup across restarts. Completion requires real frame delivery and effect presentation. Only Screen Recording consent is needed; the user controls macOS consent. The companion shows an explicitly labeled example switch rather than controlling System Settings. About reads the bundle version.

Screen access is requested asynchronously through ScreenCaptureKit's shareable-content API without creating a capture stream. Duplicate requests are disabled until completion. The permission guide includes a prominent missing-app branch, illustrated upper-list + button, actual installed-path copy action, and restart recovery. The app does not assume a Settings row exists or programmatically grant consent.
