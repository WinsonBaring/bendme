# Findings

- Native macOS 14+ app, SwiftUI settings, AppKit nonactivating overlay, ScreenCaptureKit, Metal, IOKit. No third-party runtime dependencies, network, or frame persistence.
- Reference: https://trybendy.app (read through curl 2026-09-12). Advertises hinge sensor, live Metal desktop, Silk/Shade/Frost, perspective/blur/shadow, clear angle, menu pause and Escape.
- Apple primary documentation: https://developer.apple.com/documentation/screencapturekit/capturing-screen-content-in-macos (documentation JSON retrieved directly).
- Sensor hardware: AppleSPUHIDDevice, sensor usage page 0x20, device usage 0x8A, angular position element 0x047F. Report 1, 9-bit degrees, range 0...360. No private API required to access IOHIDDevice.
- Protocol cross-check: https://github.com/samhenrigold/LidAngleSensor/blob/main/LidAngleSensor/LidAngleSensor.swift. Independently implement sensor using hardware descriptor and IOKit; do not copy third-party code/assets.
- Only affect the built-in display. Never override lid sleep. Manual settings preview works without capture or hardware.
- Default live effect off until explicitly enabled in the app; screen permission is requested from a user action.
- Git has initial commit but no remote. No GitHub MCP or context7/search_web connector available. Track locally, report limitation; no fabricated issue IDs.
- Planning skill recovered from valentines checkout into expected project location. User's uninterrupted-execution instruction applies.

## Screen Recording activation follow-up

- Ad-hoc signing uses a cdhash-based designated requirement, so rebuilding can leave a stale macOS Screen Recording entry. Off/on and restart were insufficient here; scoped reset plus adding the exact final app through System Settings worked.
- Direct execution of the bundle binary from the automation shell did not share the GUI app's permission attribution. LaunchServices (`open -n -g -W --stdout ... --stderr ... dist/BendMe.app --args --capture-test`) did and captured real frames successfully.
- Do not rebuild after permission repair unless code changes are actually needed; re-authorize the final artifact after future builds.
