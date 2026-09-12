# Current state

Issue #8 addresses the user's v0.1.2 fresh-install screenshot with no BendMe permission row. Implemented asynchronous ScreenCaptureKit consent request and prominent missing-app guidance in both permission views, with upper-list + illustration, actual app-path copy and reopen steps. Seventeen native tests and website checks passed; eleven synthetic layouts rendered, changed views reviewed. Version 0.1.3/build 4 is uploaded to Apple; notarization is processing and publication is pending.

User's current manual-test installation and privacy state are preserved; do not replace, launch or reset them automatically. Real first-use consent/registration and physical-lid acceptance are not verified by the fixtures. The guide handles absence of the row without assuming automatic registration succeeds.

App Store submission remains #2. Two empty protected diagnostic metadata folders remain under #5. Source and release artifacts are preserved.
