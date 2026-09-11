# Build scripts

`build-app.sh` builds the Swift package in release mode, constructs `dist/BendMe.app`, bundles resources, validates Info.plist, signs and verifies the result. It stops on errors. `BENDME_SIGNING_IDENTITY` optionally chooses an installed signing identity; the default is local ad-hoc signing. See [SETUP.md](../SETUP.md).

`generate-icon.swift` creates the original vector-drawn macOS icon at all required resolutions and packages it with iconutil. No external assets are used.
