#!/usr/bin/env bash

set -e

scripts/bootstrap.sh

DESTINATION=$1
DESTINATION_BIN="$DESTINATION/bin"
DESTINATION_FRAMEWORKS="$DESTINATION/Frameworks"
DESTINATION_EMBEDDED_FRAMEWORKS="$DESTINATION_FRAMEWORKS/PXCTestKit.framework/Versions/Current/Frameworks"
PRODUCTS=$PWD/build/Products
CONFIGURATION=Release

if [ -z "$DESTINATION" ]; then
    echo "Usage: scripts/build.sh destination"
    exit 1
fi

xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath="$PRODUCTS" \
  -configuration $CONFIGURATION \
  -scheme pxctest \
  -project pxctest.xcodeproj \
  clean build \
  GCC_PREPROCESSOR_DEFINITIONS='$(inherited) NDEBUG=1 NS_BLOCK_ASSERTIONS=1'

# Strip nested frameworks
rm -rf "$PRODUCTS/$CONFIGURATION/*.framework/Versions/Current/Frameworks/*"

mkdir -p "$DESTINATION_BIN"
mkdir -p "$DESTINATION_FRAMEWORKS"

[ -f "$DESTINATION_BIN/pxctest" ] && rm "$DESTINATION_BIN/pxctest"
[ -d "$DESTINATION_FRAMEWORKS/PXCTestKit.framework" ] && rm -rf "$DESTINATION_FRAMEWORKS/PXCTestKit.framework"

cp -R "$PRODUCTS/$CONFIGURATION/pxctest" "$DESTINATION_BIN"
cp -R "$PRODUCTS/$CONFIGURATION/PXCTestKit.framework" "$DESTINATION_FRAMEWORKS"

mkdir -p "$DESTINATION_EMBEDDED_FRAMEWORKS"
cp -R "$PRODUCTS/$CONFIGURATION/"*.framework "$DESTINATION_EMBEDDED_FRAMEWORKS"

xcrun swift-stdlib-tool --copy --verbose --Xcodesign --timestamp=none \
	--scan-executable "$DESTINATION_BIN/pxctest" \
	--scan-folder "$DESTINATION_FRAMEWORKS" \
	--platform macosx --destination "$DESTINATION_EMBEDDED_FRAMEWORKS" \
	--strip-bitcode

