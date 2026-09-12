#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
ARCHIVE_PATH="$PWD/dist/AppStore/BendMe.xcarchive"
ARGS=(archive -project BendMe.xcodeproj -scheme BendMe -configuration Release -destination 'generic/platform=macOS' -archivePath "$ARCHIVE_PATH")
if [[ "${1:-}" == "--unsigned" ]]; then
  xcodebuild "${ARGS[@]}" CODE_SIGNING_ALLOWED=NO
  echo "Unsigned verification archive: $ARCHIVE_PATH (not uploadable)"
else
  : "${BENDME_DEVELOPMENT_TEAM:?Set BENDME_DEVELOPMENT_TEAM to your Apple Developer team ID.}"
  xcodebuild "${ARGS[@]}" DEVELOPMENT_TEAM="$BENDME_DEVELOPMENT_TEAM" -allowProvisioningUpdates
  echo "Archive: $ARCHIVE_PATH. Export and validate with your App Store distribution credentials."
fi
