# BendMe

**A little less flat.** A free, open-source MacBook utility by [Winson Baring](https://github.com/WinsonBaring).

[Website](https://winsonbaring.github.io/bendme/) · [Download development preview](https://github.com/WinsonBaring/bendme/releases/tag/v0.1.3) · [Report an issue](https://github.com/WinsonBaring/bendme/issues)

> The direct download now contains a Developer ID signed app notarized by Apple, with its approval ticket attached. It remains a development preview distributed through GitHub, not a Mac App Store release. Re-download the DMG if you previously downloaded the unsigned preview.

A native MacBook menu-bar app that bends your live desktop as you lower the lid. The image stays anchored at the hinge, tilts into perspective, and gains progressive blur and shadow.

Built with SwiftUI, AppKit, ScreenCaptureKit, Metal, and IOKit. No third-party runtime dependencies. No accounts, telemetry, network requests, recordings, or uploaded frames.

- **Silk, Shade, and Frost** appearances with perspective, blur, and shadow controls.
- **Real lid-angle input** on compatible MacBooks, plus a manual preview without permissions.
- **Live desktop effect** on the built-in display; external monitors remain unchanged.
- **Menu-bar pause**, global **Control–Option–Command–B**, and Escape while BendMe is focused.
- **Graceful failure** for missing hardware, permission denial, capture errors, sleep, and display changes.

## Build from source

```sh
swift test
./scripts/build-app.sh
open dist/BendMe.app
```

macOS 14+, Xcode with Swift 5.10+, and a Metal-capable Mac are required. The current prebuilt download is arm64 for Apple silicon. Live folding requires a compatible lid sensor and Screen Recording permission; manual preview does not.

## Get started

Build, run, permissions, troubleshooting, and signing: [SETUP.md](SETUP.md).

Architecture and implementation boundaries: [PROJECT.md](PROJECT.md).

Verification evidence and remaining hardware checks: [docs/VERIFICATION.md](docs/VERIFICATION.md).

Original request and visual references: [docs/ORIGINAL_BRIEF.md](docs/ORIGINAL_BRIEF.md) and [image/README](image/README).

Public release work: [Issue #1](https://github.com/WinsonBaring/bendme/issues/1). App Store preparation: [Issue #2](https://github.com/WinsonBaring/bendme/issues/2).

Website development: [website/SETUP.md](website/SETUP.md). App Store archive and remaining submission requirements: [distribution/SETUP.md](distribution/SETUP.md).

Original source is [MIT-licensed](LICENSE); see [third-party notices](THIRD_PARTY_NOTICES.md), [contributing](CONTRIBUTING.md), and [security](SECURITY.md).

Local planning and issue status: [agent/planning-with-files/task_plan.md](agent/planning-with-files/task_plan.md).

BendMe is an independent implementation inspired by [Bendy](https://trybendy.app). It does not contain Bendy's code, branding, wallpapers, or audio. No affiliation is implied.

The download button serves a DMG from GitHub Releases. Open it, drag BendMe to Applications, and eject the disk. The ZIP remains available as an alternative.

BendMe appears in the Dock. Click its Dock icon to open or restore settings; the menu-bar controls remain available.

First launch opens an interactive **Setup** guide with Finder and System Settings buttons, visual permission pointers, restart recovery, and live first-effect checks. You can reopen it from the sidebar or menu bar.
