# Project

## Package layout

- [Sources/BendCore/README.md](Sources/BendCore/README.md): validated settings, fold math, packet decoder, HID sensor.
- [Sources/BendMe/README.md](Sources/BendMe/README.md): menu-bar app, SwiftUI UI, lifecycle, screen capture, GPU rendering, diagnostics.
- [Tests/BendCoreTests/README.md](Tests/BendCoreTests/README.md): deterministic unit tests.
- [scripts/README.md](scripts/README.md): release bundle generation and local signing.
- [docs/README.md](docs/README.md): brief, reference research, and verification.
- [agent/planning-with-files/README.md](agent/planning-with-files/README.md): monolithic work tracking.

Runtime dependencies: Apple system frameworks only. SwiftPM is the build system. The package has a shared core library, one executable, and one test target; no separate installable packages.

## Data and rendering

`LidSensor → AppModel → FoldGeometry → MetalRenderer`

`ScreenCaptureKit → CVPixelBuffer → CVMetalTextureCache → MetalRenderer → nonactivating NSPanel`

HID input values update the lid angle. A bounded 30 Hz feature-report read supports firmware that does not send input notifications and detects repeated read failures. Data is validated before use. A time-based filter smooths geometry at 60 Hz. The shader inversely maps a hinge-anchored perspective plane and applies a three Gaussian blur scales blended progressively, style-dependent shading, and edge feathering. Metal Performance Shaders creates the Gaussian levels without sparse-sampling ghosting.

ScreenCaptureKit captures only the built-in display, explicitly excluding the overlay window to prevent recursive capture. The overlay is nonactivating and click-through, below the system menu bar. The cursor remains the actual macOS pointer and is excluded from captured frames. Capture is capped at 2304 pixels wide with 30/60 fps settings and a queue depth of three.

Frames stay in memory. GPU completion retains the corresponding pixel buffer and Core Video texture until it is safe to release them. Settings persist in UserDefaults under the app bundle ID; sessions always start paused. Diagnostics save only the app's procedural preview artwork, never desktop frames.

## Lifecycle and boundaries

The coordinator serializes start/stop generations so late asynchronous capture starts cannot restore a paused overlay. A first-frame timeout, capture delegate failures, sensor failure handling, sleep/session notifications, and screen-change notifications remove the overlay. A global Carbon hotkey permits pause without event-monitoring permissions. Escape is local to the app.

The original wallpaper is drawn with Core Graphics; all preview and live effects use the same Metal shader. No downloaded product art ships in the app. The user-supplied references are documentation only.

Exact physical perspective depends on viewer position; this is a configurable visual illusion, not camera-based head tracking. Input coordinates are not remapped. Screen Recording permission, compatible hardware, and an open built-in display are required for the live effect. OS sleep and protected content restrictions remain in place.
