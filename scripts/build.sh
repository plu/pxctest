#!/usr/bin/env bash

set -e

DESTINATION=$1
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

mkdir -p "$DESTINATION"

mv $PRODUCTS/$CONFIGURATION/pxctest $PRODUCTS/$CONFIGURATION/*.framework $PRODUCTS/$CONFIGURATION/*.dylib $DESTINATION/
