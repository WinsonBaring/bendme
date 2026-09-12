# Build and submission

## Verify an archive without credentials

```sh
./scripts/archive-app-store.sh --unsigned
```

Expected: `ARCHIVE SUCCEEDED` and `dist/AppStore/BendMe.xcarchive`. This validates compilation and packaging only. **An unsigned archive cannot be uploaded.** It does not prove App Review acceptance.

## Prepare a signed archive

An Apple Developer Program membership, App Store Connect access, a registered bundle identifier, and suitable distribution credentials/provisioning are required. Sign in to the correct developer account in Xcode before using its automatic provisioning.

```sh
BENDME_DEVELOPMENT_TEAM=YOUR_TEAM_ID ./scripts/archive-app-store.sh
```

Use Xcode Organizer to validate and distribute the archive to App Store Connect. Verify the chosen team and `com.winsonbaring.bendme` registration before upload. The script's environment variable is configuration, not a secret.

## Submission checklist

- Confirm membership and the intended legal developer name.
- Register the bundle ID and create a macOS App Store Connect record.
- Obtain the correct distribution certificate and provisioning profile through Apple.
- Archive, export, validate, and upload a signed sandboxed build.
- Check sensor and screen capture in the **final signed sandboxed app**, with its own permission grant.
- Test physical lid motion, pause, full-screen Spaces, sleep/wake, and unsupported hardware.
- Capture real screenshots of the final app at Apple's accepted Mac screenshot sizes. Do not use the website's generated product illustration as an App Store screenshot.
- Complete age-rating, content-rights, privacy, review-contact and regional availability questions in App Store Connect using truthful account information.
- Review `metadata.json`, set the price to Free, and submit for Apple review.

## Verified here

- Unsigned Xcode archive built successfully.
- Separate sandboxed diagnostic copy read the lid sensor; no private exception entitlement was used.
- Only an Apple Development signing identity was available on this Mac. No distribution identity was found.
- Membership/App Store Connect access were not supplied or verified; no submission has occurred.

## Apple references

- [App Review Guidelines, including Mac sandbox and public API requirements](https://developer.apple.com/app-store/review/guidelines/)
- [Upload builds overview](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds-overview/)
- [Approved required-reason API declarations](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons)
- [Mac screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)

The working local app in `dist/BendMe.app` is not overwritten by archive or preview packaging. Public direct previews go to `dist/Release/`.
