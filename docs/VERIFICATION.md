# Verification — 2026-09-12

## Completed on this Mac

| Check | Result |
| --- | --- |
| `swift test -Xswiftc -warnings-as-errors` | 8 tests passed, zero failures, zero compiler warnings |
| `./scripts/build-app.sh` | Release arm64 application built; Info.plist valid |
| `codesign --verify --deep --strict dist/BendMe.app` | Passed (local ad-hoc signature) |
| Bundled executable `--diagnose` | Apple M3 Pro; built-in display present; real sensor readings from 107° to 116° observed during session |
| Bundled executable `--self-test dist/verification` | 15 real Metal/MPS renders passed; all styles at 135°, 90°, 60°, 25°, 5° |
| Open-lid GPU identity | Mean byte error 0.000 for all three styles |
| Folded GPU geometry | Black outside projected desktop; nonempty, narrowed desktop at 25° |
| Native settings UI | Inspected using native app automation (no browser); all Appearance controls fit without scrolling |
| Manual preview | Accessibility Decrement changed angle 65° → 52° → 39° → 26°; image visibly folded |
| Style selection | Frost and Shade selections changed UI and rendering; restored user's Shade choice |
| Follow lid | Preview read real 110° sensor angle and disabled manual slider |
| Settings persistence | Shade remained selected after app restart |
| Permission failure | General reports missing Screen Recording; capture smoke test exits with an explicit permission error and never requests access |

[GPU report](verification-gpu.json) contains the numeric render checks.

| Open | Folded (Frost, 25°) |
| --- | --- |
| ![Open preview](preview-open.png) | ![Folded preview](preview-folded.png) |

These are the app's original procedural artwork rendered with the actual GPU pipeline. They are not captured desktop frames.

## Activation follow-up — verified

The user requested enabling the app. System Settings showed BendMe permission enabled, but the current ad-hoc build still reported denied. Toggling and restarting did not repair it. Resetting only BendMe's ScreenCapture entry and re-adding the exact current app bundle in System Settings did. The native UI now shows **LIVE**, **Pause BendMe**, and **Follow lid: on**. Shade and the 100° clear angle were preserved. Observed lid: 112°.

A LaunchServices smoke test returned:

```text
PASS: 3 complete live frames at 1512×982; overlay exclusion resolved; capture stopped. No desktop frames saved.
```

The test stream stopped; the main app remained LIVE. This confirms real desktop capture and successful exclusion lookup for the overlay window. No desktop frames were persisted. No app rebuild was performed during the permission repair.

Reproduce in the GUI app's authorization context:

```sh
open -n -g -W --stdout /tmp/bendme-capture.out --stderr /tmp/bendme-capture.err dist/BendMe.app --args --capture-test
cat /tmp/bendme-capture.out /tmp/bendme-capture.err
```

Direct execution from the automation terminal still reported permission denied, while the GUI and LaunchServices-launched test succeeded. This is a macOS launch-responsibility distinction; the direct CLI result is not evidence that the active GUI app cannot capture.

Physical lid-to-desktop alignment, visual recursion under an actively folded overlay, full-screen Spaces, global pause during a visible effect, and sleep/wake recovery remain **unverified** end to end. Gently lower the lid below 100° to exercise the live fold. The effect intentionally clears above that angle.

## Delivery boundaries

The application is a local arm64 build for this Mac, not a notarized public release. It has no remote repository or available GitHub MCP, so no GitHub issue was created or closed and no commit was pushed. Local planning and commit preserve the implementation for follow-up.
