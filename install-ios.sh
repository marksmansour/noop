#!/bin/zsh
# Build NOOP and install it on the USB-connected iPhone (free Personal Team; re-run every 7 days).
# Needs Config/BundleIdSecrets.xcconfig (BUNDLE_ID_PREFIX + DEVELOPMENT_TEAM) and the iPhone unlocked.
set -euo pipefail
cd "$(dirname "$0")"

XCODEGEN=$(command -v xcodegen || echo ~/.local/xcodegen-dl/xcodegen/bin/xcodegen)
DERIVED=~/Library/Developer/Xcode/DerivedData/noop-cli

DEVICE=$(xcrun devicectl list devices 2>/dev/null | awk '/connected/ && /iPhone/ {for (i=1;i<=NF;i++) if ($i ~ /^[0-9A-F]{8}-[0-9A-F]{16}$/) print $i}' | head -1)
[[ -n "$DEVICE" ]] || { echo "No connected iPhone found. Plug it in and unlock it."; exit 1; }

"$XCODEGEN" generate --quiet
xcodebuild -project Strand.xcodeproj -scheme NOOPiOS -destination "id=$DEVICE" -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates -allowProvisioningDeviceRegistration -quiet build
xcrun devicectl device install app --device "$DEVICE" "$DERIVED/Build/Products/Debug-iphoneos/NOOP.app"
echo "Installed NOOP on $DEVICE"
