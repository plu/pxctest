#!/usr/bin/env bash

set -e

DESTINATION=$1
DESTINATION_BIN="$DESTINATION/bin"
DESTINATION_FRAMEWORKS="$DESTINATION/Frameworks"
PRODUCTS=$PWD/build/Products
CONFIGURATION=Release

if [ -z "$DESTINATION" ]; then
    echo "Usage: scripts/build.sh destination"
    exit 1
fi

pushd Dependencies/Commander
xcrun swift package generate-xcodeproj --output ../
popd

xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath="$PRODUCTS" \
  -configuration $CONFIGURATION \
  -scheme pxctest \
  -project pxctest.xcodeproj \
  GCC_PREPROCESSOR_DEFINITIONS='$(inherited) NDEBUG=1 NS_BLOCK_ASSERTIONS=1'

xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath="$PRODUCTS" \
  -configuration $CONFIGURATION \
  -scheme pxctest-list-tests \
  -project pxctest.xcodeproj \
  -sdk iphonesimulator

# Strip nested frameworks
rm -rf $PRODUCTS/$CONFIGURATION/*.framework/Versions/Current/Frameworks/*

mkdir -p "$DESTINATION_BIN"
mkdir -p "$DESTINATION_FRAMEWORKS"

[ -f "$DESTINATION_BIN/pxctest" ] && rm "$DESTINATION_BIN/pxctest"

for framework in $PRODUCTS/$CONFIGURATION/*.framework; do
    framework=$(basename $framework)
    [ -d "$DESTINATION_FRAMEWORKS/$framework" ] && rm -r "$DESTINATION_FRAMEWORKS/$framework"
done

cp -R $PRODUCTS/$CONFIGURATION/pxctest $DESTINATION_BIN
cp -R $PRODUCTS/$CONFIGURATION/*.framework $PRODUCTS/$CONFIGURATION/*.dylib $DESTINATION_FRAMEWORKS
