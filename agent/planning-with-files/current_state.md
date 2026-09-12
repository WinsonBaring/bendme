# Current state — release 0.1.5

User resumed direct Developer ID notarization and website publication. Apple accepted 0.1.5/build 6; strict signature, stapled ticket and Gatekeeper passed. Signed-app GPU self-test passed (15 renders). Swift 17 tests and website lint/3 tests/build passed. Mounted DMG passed version/link/signature/ticket/Gatekeeper validation. Public v0.1.5 DMG/ZIP/checksum hashes match local artifacts. Pages run 34673091473 succeeded; live HTTP 200 confirms new download, setup flow and visible pause guidance.

The release includes the light interface, branded header, subtle developer/profile and public-source links, compact native consent, and Start → Appearance navigation. Pause guidance uses Appearance → Pause BendMe and menu-bar → Pause effect. Keyboard shortcut failure is not reproduced or fixed; tracked in #11. #10 tracks release/UI review. App Store submission is separate under #2; this is a notarized direct download.

Installed app and permission state remain untouched. User can manually install the new download for live GUI and physical-lid review. #5 retains previously noted protected empty diagnostic metadata.

Local social kit (#12): five platform drafts, posting tracker, source review and selected media prepared under ignored social-media/. Nothing posted or scheduled. Draft content and source media are not committed; only ignore and workflow metadata are tracked.

Standalone portfolio is published at https://winsonbaring.github.io/ from ignored portfolio/, with its own Git repository and Issue #1 at WinsonBaring/winsonbaring.github.io. BendMe app/source remains unchanged.
