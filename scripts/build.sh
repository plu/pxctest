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
xcrun swift package fetch
popd

xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath="$PRODUCTS" \
  -configuration $CONFIGURATION \
  -scheme pxctest \
  -project pxctest.xcodeproj

mkdir -p "$DESTINATION"

mv $PRODUCTS/$CONFIGURATION/pxctest $PRODUCTS/$CONFIGURATION/*.framework $DESTINATION/
