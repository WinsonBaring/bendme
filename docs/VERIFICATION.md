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

## Still requires permission / physical acceptance

Screen Recording is **not granted** in the running app. The user was asked for confirmation before expanding screen access. No confirmation had arrived when this verification record was written. The computer-use tool requires confirmation before granting that permission; the app does not bypass it.

Consequently live desktop capture, recursive-overlay exclusion in an active stream, physical lid-to-desktop alignment, full-screen Spaces, global pause during an active effect, and sleep/wake recovery have **not** been verified end to end. Their code paths are implemented, but the GPU tests do not prove them.

After granting BendMe Screen Recording and reopening if requested:

```sh
dist/BendMe.app/Contents/MacOS/BendMe --capture-test
```

Expected: `PASS` with complete frame count and dimensions, resolved overlay exclusion, and stopped capture. No frames are saved. macOS may attribute a CLI invocation to its launching terminal; use the in-app Enable control if CLI and app permission results differ.

Then choose Enable BendMe, gently lower the lid below 100°, open it again, and test Control–Option–Command–B while another app is focused. Re-enable and check sleep/wake and display changes. Do not treat these physical acceptance checks as completed until observed.

## Delivery boundaries

The application is a local arm64 build for this Mac, not a notarized public release. It has no remote repository or available GitHub MCP, so no GitHub issue was created or closed and no commit was pushed. Local planning and commit preserve the implementation for follow-up.
