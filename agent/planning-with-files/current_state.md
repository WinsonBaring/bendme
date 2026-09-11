# Current state

Native BendMe implementation and local package are built. The app is available at `dist/BendMe.app`; source has no third-party runtime dependencies. UI, three effects, manual preview, live sensor readings, capture service, lifecycle handling, emergency shortcut, and documentation are implemented.

Verified: 8 tests with warnings as errors; release build; strict local signature; 15 GPU renders with exact open-lid identity; hardware sensor on Apple M3 Pro; native UI fit, style switching, manual angle changes, follow-lid preview and persisted settings.

Follow-up 2026-09-12: User requested activation. A stale Screen Recording entry stayed on in System Settings while the current ad-hoc-signed app reported no access. A scoped `tccutil reset ScreenCapture local.bendme.mac`, then adding the exact `dist/BendMe.app` bundle through System Settings and Quit & Reopen, restored access. BendMe is now LIVE with Follow lid on, Shade selected and clear angle 100°. The observed lid angle was 112° (above the clear angle).

Verified live capture through LaunchServices: 3 complete frames at 1512×982; overlay exclusion resolved; smoke-test stream stopped cleanly and the primary app stayed LIVE. No desktop frames were saved. Direct terminal invocations still report a different permission state because of macOS responsibility attribution; use `open -n -g -W ... --args --capture-test` for the app's authorization context.

Outstanding: physical lid-to-desktop alignment, sleep/wake, Spaces, and pause during an actually visible fold remain manual acceptance checks. No rebuild was performed during this activation fix, preserving the newly granted app signature.

GitHub tracking and pushing are unavailable: this repository has no remote and the session exposes no GitHub MCP. Do not invent issue IDs or claim remote completion. Public distribution also needs Developer ID signing/notarization; current bundle is a local arm64 build.

See `docs/VERIFICATION.md` for exact checks and limitations.
