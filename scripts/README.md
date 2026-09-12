# Build scripts

`build-app.sh` builds the Swift package in release mode, constructs `dist/BendMe.app`, bundles resources, validates Info.plist, signs and verifies the result. It stops on errors. `BENDME_SIGNING_IDENTITY` optionally chooses an installed signing identity; the default is local ad-hoc signing. See [SETUP.md](../SETUP.md).

`generate-icon.swift` creates the original vector-drawn macOS icon at all required resolutions and packages it with iconutil. No external assets are used.

`package-preview.sh` creates the public arm64 preview and SHA-256 checksum in `dist/Release`, preserving the currently authorized app in `dist/BendMe.app`. `generate-xcode-project.py` generates the native Xcode target from canonical sources. `archive-app-store.sh --unsigned` validates an archive without credentials; signed archives require the user's developer team and Xcode account setup.
