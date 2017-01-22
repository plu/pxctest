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

# Strip nested frameworks
rm -rf $PRODUCTS/$CONFIGURATION/*.framework/Versions/Current/Frameworks/*

# Relocate dependencies
shopt -s extglob
mkdir $PRODUCTS/$CONFIGURATION/PXCTestKit.framework/Versions/Current/Frameworks/
mv $PRODUCTS/$CONFIGURATION/!(PXCTestKit).framework $PRODUCTS/$CONFIGURATION/PXCTestKit.framework/Versions/Current/Frameworks/
shopt -u extglob

mkdir -p "$DESTINATION/bin"
mkdir -p "$DESTINATION/Frameworks"

cp -R $PRODUCTS/$CONFIGURATION/pxctest $DESTINATION/bin
cp -R $PRODUCTS/$CONFIGURATION/*.framework $PRODUCTS/$CONFIGURATION/*.dylib $DESTINATION/Frameworks
