# Release pause — user instruction

Do not bump versions, submit to Apple, notarize, tag, publish releases or deploy website updates until the user explicitly resumes releases. Focus on local interface review and improvement. Current UI previews are app-owned renders with synthetic setup state, not a live permission test.

# Current state

Issue #9 complete: v0.1.4/build 5 removes the floating guide, imitation controls and verbose permission help. Setup uses one native ScreenCaptureKit consent button and concise conditional Settings/reopen recovery. macOS retains approval authority. User prefers this simple flow.

Published and Apple-notarized. Signature/ticket/Gatekeeper/mounted DMG and all public hashes verified. Seventeen tests, eight rendered layout fixtures, website checks, Pages 34669954828 and GitHub Checks 34669954841 passed. Live site points to 0.1.4 with concise consent copy.

User's installed app, running session and privacy state remain unchanged. Do not install/launch/reset automatically; user will test manually. Actual native first-use consent and automatic Settings registration are not verified by synthetic fixtures.

App Store submission remains #2; protected empty diagnostic metadata remains #5.
