# Current state

Native BendMe implementation and local package are built. The app is available at `dist/BendMe.app`; source has no third-party runtime dependencies. UI, three effects, manual preview, live sensor readings, capture service, lifecycle handling, emergency shortcut, and documentation are implemented.

Verified: 8 tests with warnings as errors; release build; strict local signature; 15 GPU renders with exact open-lid identity; hardware sensor on Apple M3 Pro; native UI fit, style switching, manual angle changes, follow-lid preview and persisted settings.

Outstanding: Screen Recording permission is not granted. Confirmation was requested and remains pending. Live desktop capture and physical lid/sleep/Spaces acceptance are not verified. The app is left paused; manual and sensor previews work. The capture smoke test is available after permission.

GitHub tracking and pushing are unavailable: this repository has no remote and the session exposes no GitHub MCP. Do not invent issue IDs or claim remote completion. Public distribution also needs Developer ID signing/notarization; current bundle is a local arm64 build.

See `docs/VERIFICATION.md` for exact checks and limitations.
