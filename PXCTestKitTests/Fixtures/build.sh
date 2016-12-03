#!/usr/bin/env bash

rm -r *.app *.xctestrun

pushd Sample.source
xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath=$PWD/../ \
  -scheme Sample \
  -project Sample.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 5,OS=latest' \
  clean build-for-testing
popd

pushd Crash.source
xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath=$PWD/../ \
  -scheme Crash \
  -project Crash.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 5,OS=latest' \
  clean build-for-testing
popd

mv Debug-iphonesimulator/* .
rmdir Debug-iphonesimulator

rm -r *.app/Frameworks
rm -r *.app/_CodeSignature
rm -r *.app/PlugIns/*.xctest/_CodeSignature

sed -i.bak 's!/Debug-iphonesimulator!!g' *.xctestrun
rm *.bak
