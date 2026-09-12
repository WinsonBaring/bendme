#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
RELEASE_DIR="$PWD/dist/Release"
BENDME_OUTPUT_DIR="$RELEASE_DIR" BENDME_BUNDLE_ID=com.winsonbaring.bendme ./scripts/build-app.sh
ditto -c -k --sequesterRsrc --keepParent "$RELEASE_DIR/BendMe.app" "$RELEASE_DIR/BendMe-macOS-arm64.zip"
./scripts/package-dmg.sh
(
  cd "$RELEASE_DIR"
  shasum -a 256 BendMe-macOS-arm64.zip BendMe-macOS-arm64.dmg > SHA256SUMS.txt
)
echo "Development preview and checksum: $RELEASE_DIR"
