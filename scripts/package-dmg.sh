#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
RELEASE_DIR="${BENDME_RELEASE_DIR:-$PWD/dist/Release}"
APP="$RELEASE_DIR/BendMe.app"
DMG="$RELEASE_DIR/BendMe-macOS-arm64.dmg"
[[ -d "$APP" ]] || { echo "Build the preview first with scripts/package-preview.sh" >&2; exit 1; }
codesign --verify --deep --strict "$APP"
if [[ "${BENDME_NOTARIZED:-0}" == 1 ]]; then
  xcrun stapler validate "$APP"
  spctl --assess --type execute --verbose=2 "$APP"
elif [[ "${BENDME_NOTARIZED:-0}" != 0 ]]; then
  echo 'BENDME_NOTARIZED must be 0 or 1' >&2; exit 1
fi
STAGING=$(mktemp -d "${TMPDIR:-/tmp}/bendme-dmg.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
mkdir "$STAGING/volume"
ditto "$APP" "$STAGING/volume/BendMe.app"
ln -s /Applications "$STAGING/volume/Applications"
cat > "$STAGING/volume/Read Me.txt" <<'EOF'
BendMe development preview

Open BendMe to start its interactive Setup guide. It helps you place
BendMe in Applications, open the correct Screen Recording settings,
and try your first live effect. Follow the buttons in the app; a small
companion guide stays visible while you use System Settings.

Eject this disk after opening your installed copy from Applications.

Requires Apple silicon and macOS 14 or later. The live effect requires
a compatible MacBook lid sensor. Manual preview works without it.

Source and setup: https://github.com/WinsonBaring/bendme
Website: https://winsonbaring.github.io/bendme/
EOF
if [[ "${BENDME_NOTARIZED:-0}" == 1 ]]; then
  cat >> "$STAGING/volume/Read Me.txt" <<'EOF'

The included app is Developer ID signed and notarized by Apple, with
its approval ticket attached. It is distributed independently from
the Mac App Store. macOS may still ask you to confirm the first launch.
EOF
else
  cat >> "$STAGING/volume/Read Me.txt" <<'EOF'

This preview is ad-hoc signed, not Apple-notarized. macOS may block it.
Build from source or wait for a signed release if you prefer.
Do not disable macOS security globally.
EOF
fi
hdiutil create -volname BendMe -srcfolder "$STAGING/volume" -format UDZO -ov "$STAGING/BendMe.dmg"
hdiutil verify "$STAGING/BendMe.dmg"
mv "$STAGING/BendMe.dmg" "$DMG"
(
  cd "$RELEASE_DIR"
  shasum -a 256 BendMe-macOS-arm64.dmg > BendMe-macOS-arm64.dmg.sha256
)
echo "DMG and checksum: $DMG"
