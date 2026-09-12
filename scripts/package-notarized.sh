#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
APP="$PWD/dist/DeveloperID/Notarized/BendMe.app"
RELEASE_DIR="$PWD/dist/NotarizedRelease"
[[ -d "$APP" ]] || { echo 'Run scripts/notarize-direct.sh export after Apple acceptance.' >&2; exit 1; }
codesign --verify --deep --strict "$APP"
xcrun stapler validate "$APP"
spctl --assess --type execute --verbose=2 "$APP"
mkdir -p "$RELEASE_DIR"
STAGING=$(mktemp -d "$RELEASE_DIR/.package.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
ditto "$APP" "$STAGING/BendMe.app"
BENDME_RELEASE_DIR="$STAGING" BENDME_NOTARIZED=1 ./scripts/package-dmg.sh
ditto -c -k --sequesterRsrc --keepParent "$STAGING/BendMe.app" "$STAGING/BendMe-macOS-arm64.zip"
(
  cd "$STAGING"
  shasum -a 256 BendMe-macOS-arm64.zip BendMe-macOS-arm64.dmg > SHA256SUMS.txt
)
for NAME in BendMe-macOS-arm64.dmg BendMe-macOS-arm64.dmg.sha256 BendMe-macOS-arm64.zip SHA256SUMS.txt; do
  mv "$STAGING/$NAME" "$RELEASE_DIR/$NAME"
done
echo "Notarized app packaged at $RELEASE_DIR. Public assets have not been changed."
