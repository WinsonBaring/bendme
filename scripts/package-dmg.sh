#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
RELEASE_DIR="$PWD/dist/Release"
APP="$RELEASE_DIR/BendMe.app"
DMG="$RELEASE_DIR/BendMe-macOS-arm64.dmg"
[[ -d "$APP" ]] || { echo "Build the preview first with scripts/package-preview.sh" >&2; exit 1; }
codesign --verify --deep --strict "$APP"
STAGING=$(mktemp -d "${TMPDIR:-/tmp}/bendme-dmg.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
mkdir "$STAGING/volume"
ditto "$APP" "$STAGING/volume/BendMe.app"
ln -s /Applications "$STAGING/volume/Applications"
cat > "$STAGING/volume/Read Me.txt" <<'EOF'
BendMe development preview

Drag BendMe.app to Applications, eject this disk, then open BendMe
from Applications. Enable BendMe and grant Screen Recording permission
in System Settings when requested.

Requires Apple silicon and macOS 14 or later. The live effect requires
a compatible MacBook lid sensor. Manual preview works without it.

This preview is ad-hoc signed, not Apple-notarized. macOS may block it.
Build from source or wait for a signed release if you prefer.
Do not disable macOS security globally.

Source and setup: https://github.com/WinsonBaring/bendme
Website: https://winsonbaring.github.io/bendme/
EOF
hdiutil create -volname BendMe -srcfolder "$STAGING/volume" -format UDZO -ov "$STAGING/BendMe.dmg"
hdiutil verify "$STAGING/BendMe.dmg"
mv "$STAGING/BendMe.dmg" "$DMG"
(
  cd "$RELEASE_DIR"
  shasum -a 256 BendMe-macOS-arm64.dmg > BendMe-macOS-arm64.dmg.sha256
)
echo "DMG and checksum: $DMG"
