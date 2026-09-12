# Current state

Issue #8 addresses the user's v0.1.2 fresh-install screenshot with no BendMe permission row. Implemented asynchronous ScreenCaptureKit consent request and prominent missing-app guidance in both permission views, with upper-list + illustration, actual app-path copy and reopen steps. Seventeen native tests and website checks passed; eleven synthetic layouts rendered, changed views reviewed. Version 0.1.3/build 4 is Apple-notarized and published. Stapled ticket, signature, Gatekeeper and mounted DMG checks passed. All four public assets match local SHA-256 hashes. Pages deployment 34669618518 and GitHub Checks 34669618513 passed. Live website contains v0.1.3 download and missing-app instructions. Issue #8 implementation and release are complete; user acceptance of real first-use permission behavior remains manual.

User's current manual-test installation and privacy state are preserved; do not replace, launch or reset them automatically. Real first-use consent/registration and physical-lid acceptance are not verified by the fixtures. The guide handles absence of the row without assuming automatic registration succeeds.

App Store submission remains #2. Two empty protected diagnostic metadata folders remain under #5. Source and release artifacts are preserved.
