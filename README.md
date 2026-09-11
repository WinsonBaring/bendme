# BendMe

A native MacBook menu-bar app that bends your live desktop as you lower the lid. The image stays anchored at the hinge, tilts into perspective, and gains progressive blur and shadow.

Built with SwiftUI, AppKit, ScreenCaptureKit, Metal, and IOKit. No third-party runtime dependencies. No accounts, telemetry, network requests, recordings, or uploaded frames.

- **Silk, Shade, and Frost** appearances with perspective, blur, and shadow controls.
- **Real lid-angle input** on compatible MacBooks, plus a manual preview without permissions.
- **Live desktop effect** on the built-in display; external monitors remain unchanged.
- **Menu-bar pause**, global **Control–Option–Command–B**, and Escape while BendMe is focused.
- **Graceful failure** for missing hardware, permission denial, capture errors, sleep, and display changes.

## Get started

Build, run, permissions, troubleshooting, and signing: [SETUP.md](SETUP.md).

Architecture and implementation boundaries: [PROJECT.md](PROJECT.md).

Verification evidence and remaining hardware checks: [docs/VERIFICATION.md](docs/VERIFICATION.md).

Original request and visual references: [docs/ORIGINAL_BRIEF.md](docs/ORIGINAL_BRIEF.md) and [image/README](image/README).

Local planning and issue status: [agent/planning-with-files/task_plan.md](agent/planning-with-files/task_plan.md).

BendMe is an independent implementation inspired by [Bendy](https://trybendy.app). It does not contain Bendy's code, branding, wallpapers, or audio. No affiliation is implied.
