# Distribution project

The archive target is `BendMe.xcodeproj`, scheme `BendMe`, arm64, macOS 14+. It uses `com.winsonbaring.bendme` as the proposed public bundle identifier. This identifier still needs registration in the user's Apple Developer account.

`metadata.json` is a reviewable draft, not an API submission. `AppStore.entitlements` enables App Sandbox and HID/USB device access. `PrivacyInfo.xcprivacy` declares UserDefaults use for app-local preferences and boot-relative elapsed time for animation/capture timing; it declares no tracking or collection. `Assets.xcassets` contains the original app icon at required resolutions.

No team, distribution certificate, provisioning profile, API private key, or Apple credentials are committed. The archive script accepts a team ID through `BENDME_DEVELOPMENT_TEAM` and uses Xcode's approved account provisioning path.

Direct distribution uses `scripts/notarize-direct.sh` and Xcode's existing paid-team session. Automatic Developer ID export can use managed signing without a locally listed Developer ID identity. The direct archive disables App Sandbox, retains hardened runtime and avoids App Store-only entitlements. Artifact publication requires successful Apple acceptance, ticket validation and Gatekeeper assessment.

Current app version is 0.1.1/build 2. Dock activation is enabled in distribution/Info.plist and the app lifecycle; archives can be isolated with BENDME_NOTARIZATION_DIR.
