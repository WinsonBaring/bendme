# Build scripts

`build-app.sh` builds the Swift package in release mode, constructs `dist/BendMe.app`, bundles resources, validates Info.plist, signs and verifies the result. It stops on errors. `BENDME_SIGNING_IDENTITY` optionally chooses an installed signing identity; the default is local ad-hoc signing. See [SETUP.md](../SETUP.md).

`generate-icon.swift` creates the original vector-drawn macOS icon at all required resolutions and packages it with iconutil. No external assets are used.

`package-preview.sh` creates the public arm64 preview and SHA-256 checksum in `dist/Release`, preserving the currently authorized app in `dist/BendMe.app`. `generate-xcode-project.py` generates the native Xcode target from canonical sources. `archive-app-store.sh --unsigned` validates an archive without credentials; signed archives require the user's developer team and Xcode account setup.

`package-dmg.sh` wraps the existing `dist/Release/BendMe.app` in a verified compressed DMG with an Applications shortcut and installation notes. It emits a dedicated `.dmg.sha256` checksum without rebuilding the app. `package-preview.sh` now produces both ZIP and DMG formats.

`notarize-direct.sh submit|export` archives and uploads via Xcode's configured paid team, then retrieves and verifies Apple's accepted app. `package-dmg.sh` accepts an isolated `BENDME_RELEASE_DIR`; `BENDME_NOTARIZED=1` requires a valid attached app ticket and Gatekeeper acceptance before changing the installation notes. No public download is uploaded automatically by these scripts.

`package-notarized.sh` packages the accepted app into DMG/ZIP with fresh checksums under `dist/NotarizedRelease`, preserving the original installation and preview artifacts. It refuses to proceed without a valid stapled ticket and Gatekeeper acceptance.

`finish-notarization.py` checks the existing submission once per minute for up to 24 hours, exports and verifies acceptance, then packages the app. `--publish` additionally verifies the mounted DMG, builds the updated website, replaces release assets and checks their public hashes, pushes the website, and verifies its live copy. Run publishing from an isolated clean checkout; it stops if remote source changed while waiting. State is recorded in `dist/DeveloperID/notarization-status.json`. It never resubmits or reads account credentials.
