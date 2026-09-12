#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD/dist/DeveloperID"
ARCHIVE="$ROOT/BendMe.xcarchive"
case "${1:-}" in
  submit)
    : "${BENDME_DEVELOPMENT_TEAM:?Set the paid developer team ID configured in Xcode.}"
    mkdir -p "$ROOT"
    # Archive with automatic development signing; export selects Developer ID.
    xcodebuild archive -project BendMe.xcodeproj -scheme BendMe \
      -configuration Release -destination 'generic/platform=macOS' \
      -archivePath "$ARCHIVE" DEVELOPMENT_TEAM="$BENDME_DEVELOPMENT_TEAM" \
      CODE_SIGN_ENTITLEMENTS='' ENABLE_APP_SANDBOX=NO \
      ENABLE_HARDENED_RUNTIME=YES -allowProvisioningUpdates
    python3 - "$ROOT/ExportOptions.plist" "$BENDME_DEVELOPMENT_TEAM" <<'PY'
import plistlib, sys
from pathlib import Path
Path(sys.argv[1]).write_bytes(plistlib.dumps({
    'method': 'developer-id', 'destination': 'upload',
    'teamID': sys.argv[2], 'signingStyle': 'automatic',
}))
PY
    xcodebuild -exportArchive -archivePath "$ARCHIVE" \
      -exportOptionsPlist "$ROOT/ExportOptions.plist" \
      -exportPath "$ROOT/Export" -allowProvisioningUpdates
    echo 'Uploaded to Apple. Run this script with export to check acceptance; upload is not approval.'
    ;;
  export)
    xcodebuild -exportNotarizedApp -archivePath "$ARCHIVE" -exportPath "$ROOT/Notarized"
    APP="$ROOT/Notarized/BendMe.app"
    codesign --verify --deep --strict "$APP"
    xcrun stapler validate "$APP"
    spctl --assess --type execute --verbose=2 "$APP"
    echo "Apple-approved app verified at $APP. Package without changing its contents."
    ;;
  *) echo 'Usage: scripts/notarize-direct.sh submit|export' >&2; exit 2 ;;
esac
