# BendMe application

`BendMeMain.swift` creates the menu bar and settings window. `AppModel.swift` coordinates hardware, permissions, lifecycle, shortcuts, capture, and overlays. `SettingsView.swift` provides Appearance, General and About. `DesktopCapture.swift` owns ScreenCaptureKit. `MetalRenderer.swift` owns texture lifetime and GPU submission. `PreviewArtwork.swift` draws the original landscape. `Diagnostics.swift` implements hardware diagnostics, offscreen GPU tests, and an opt-in live capture smoke test. [Resources](Resources/README.md) contains the shared shader.

Build and launch through [the root setup guide](../../SETUP.md); the app needs its bundled shader resource.

The same files compile in the native Xcode target. Conditional BendCore imports avoid duplicating application logic, and resource lookup supports the Xcode app bundle and SwiftPM CLI.

Normal launches now use regular AppKit activation so the app appears in the Dock. Reopening activates the settings window and restores it from minimization; capture diagnostics remain an accessory process.

`SetupView.swift` provides installation, native Screen Recording consent and first-effect setup. `AppModel` polls actual permission while Setup is visible and persists unfinished setup across restarts. Completion requires real frames and effect presentation. About reads the bundle version.

Permission setup has one primary button: an asynchronous ScreenCaptureKit shareable-content request without creating a capture stream. Duplicate requests are disabled. If access remains unavailable, the primary button changes to a manual System Settings action and a brief reopen action appears. The app never redirects automatically after a permission request; the user chooses Open System Settings in Apple's dialog or explicitly clicks the app's button. No floating guide, imitation Settings controls, clipboard helper or Accessibility access is used. macOS owns consent; the app never grants it itself.

After permission is confirmed, Setup shows a short Try BendMe card with one start/pause action. Starting, active-lid guidance, sensor recovery and capture errors appear only when relevant. The progress strip ends after installation/permission; completion is a compact All set action. Actual permission and rendered-effect completion checks are unchanged.

`AppTheme.swift` shares the light palette across Setup and Settings. The AppKit window uses Aqua so native controls and title bar agree. Every sidebar row uses the same full-width selection and keyboard-focus treatment, replacing the label-sized system focus halo while preserving keyboard focus and selected accessibility state.

A small “Made by” credit with a GitHub icon links to the developer profile in the sidebar and About; no personal name is displayed. About also links to the public repository, website and issue tracker using native external links. No embedded browser or analytics is added.

The sidebar header reuses the actual BendMe app icon in full color instead of a generic laptop symbol. Brand images share resource resolution across SwiftPM and the packaged Xcode app.
