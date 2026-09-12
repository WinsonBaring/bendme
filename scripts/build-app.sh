#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"
OUTPUT_DIR="${BENDME_OUTPUT_DIR:-$PWD/dist}"
APP_PATH="$OUTPUT_DIR/BendMe.app"
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
cp "$BIN_DIR/BendMe" "$APP_PATH/Contents/MacOS/BendMe"
RESOURCE_BUNDLE="$BIN_DIR/BendMe_BendMe.bundle"
if [[ ! -d "$RESOURCE_BUNDLE" ]]; then
  echo "Missing Swift resource bundle: $RESOURCE_BUNDLE" >&2
  exit 1
fi
if [[ -d "$APP_PATH/BendMe_BendMe.bundle" ]]; then
  rm -rf "$APP_PATH/BendMe_BendMe.bundle"
fi
ditto "$RESOURCE_BUNDLE" "$APP_PATH/Contents/Resources/BendMe_BendMe.bundle"
swift scripts/generate-icon.swift "$APP_PATH/Contents/Resources/AppIcon.icns"
cp distribution/PrivacyInfo.xcprivacy "$APP_PATH/Contents/Resources/PrivacyInfo.xcprivacy"
cat > "$APP_PATH/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>BendMe</string>
<key>CFBundleIdentifier</key><string>local.bendme.mac</string>
<key>CFBundleName</key><string>BendMe</string>
<key>CFBundleDisplayName</key><string>BendMe</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.4</string>
<key>CFBundleVersion</key><string>5</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><false/>
<key>NSHighResolutionCapable</key><true/>
<key>NSScreenCaptureUsageDescription</key><string>BendMe renders your live desktop as the lid moves. Frames stay on this Mac and are never recorded or uploaded.</string>
</dict></plist>
PLIST
if [[ -n "${BENDME_BUNDLE_ID:-}" ]]; then
  if [[ ! "$BENDME_BUNDLE_ID" =~ ^[A-Za-z0-9]+([.-][A-Za-z0-9]+)+$ ]]; then
    echo "Invalid BENDME_BUNDLE_ID" >&2
    exit 1
  fi
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BENDME_BUNDLE_ID" "$APP_PATH/Contents/Info.plist"
fi
plutil -lint "$APP_PATH/Contents/Info.plist"
codesign --force --deep --sign "${BENDME_SIGNING_IDENTITY:--}" "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"
echo "Built and verified: $APP_PATH"
