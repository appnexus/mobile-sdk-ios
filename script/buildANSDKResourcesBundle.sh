
SOURCE_DIR="./sourcefiles/Resources/"

BUNDLE_DIR="ANSDKResources.bundle"

mkdir -p "$BUNDLE_DIR"
cp -R "$SOURCE_DIR"/* "$BUNDLE_DIR"
cp -R "$SOURCE_DIR"/images/ "$BUNDLE_DIR"

rm -rf "$BUNDLE_DIR"/ANInterstitialAdViewController.xib
rm -rf "$BUNDLE_DIR"/anjam.js
rm -rf "$BUNDLE_DIR"/ANMRAID.bundle
rm -rf "$BUNDLE_DIR"/MobileVastPlayer.js
rm -rf "$BUNDLE_DIR"/nativeRenderer.html
rm -rf "$BUNDLE_DIR"/optionsparser.js
rm -rf "$BUNDLE_DIR"/vastVideo.html
rm -rf "$BUNDLE_DIR"/images
rm -rf "$BUNDLE_DIR"/interstitial_closebox.png
rm -rf "$BUNDLE_DIR"/interstitial_closebox@2x.png
rm -rf "$BUNDLE_DIR"/interstitial_flat_closebox.png
rm -rf "$BUNDLE_DIR"/interstitial_flat_closebox@2x.png
rm -rf "$BUNDLE_DIR"/interstitial_flat_closebox@3x.png
rm -rf "$BUNDLE_DIR"/sdkjs.js
rm -rf "$BUNDLE_DIR"/ASTMediationManager.js



echo "Bundle creation completed: $BUNDLE_DIR"


