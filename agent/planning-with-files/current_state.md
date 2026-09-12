# Current state — release 0.1.5

User resumed direct Developer ID notarization and website publication. Apple accepted 0.1.5/build 6; strict signature, stapled ticket and Gatekeeper passed. Signed-app GPU self-test passed (15 renders). Swift 17 tests and website lint/3 tests/build passed. Packaging and public deployment verification remain in progress.

The release includes the light interface, branded header, subtle developer/profile and public-source links, compact native consent, and Start → Appearance navigation. Pause guidance uses Appearance → Pause BendMe and menu-bar → Pause effect. Keyboard shortcut failure is not reproduced or fixed; tracked in #11. #10 tracks release/UI review. App Store submission is separate under #2; this is a notarized direct download.

Installed app and permission state remain untouched. User can manually install the new download for live GUI and physical-lid review. #5 retains previously noted protected empty diagnostic metadata.
