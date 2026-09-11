# BendMe application

`BendMeMain.swift` creates the menu bar and settings window. `AppModel.swift` coordinates hardware, permissions, lifecycle, shortcuts, capture, and overlays. `SettingsView.swift` provides Appearance, General and About. `DesktopCapture.swift` owns ScreenCaptureKit. `MetalRenderer.swift` owns texture lifetime and GPU submission. `PreviewArtwork.swift` draws the original landscape. `Diagnostics.swift` implements hardware diagnostics, offscreen GPU tests, and an opt-in live capture smoke test. [Resources](Resources/README.md) contains the shared shader.

Build and launch through [the root setup guide](../../SETUP.md); the app needs its bundled shader resource.
