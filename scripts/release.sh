#!/usr/bin/env bash

set -e

PXCTEST_PLIST='pxctest/info.plist'
NEW_VERSION="$(./scripts/get_version.sh)"

echo "New version is $NEW_VERSION"

NEW_RELEASE_DIR="build/releases/$NEW_VERSION"

echo "Cleaning release directory"

rm -rf "$NEW_RELEASE_DIR"

BUILT_BIN_NAME='pxctest'
BUILT_BIN_PATH="$NEW_RELEASE_DIR/bin/$BUILT_BIN_NAME"
BUILT_FRAMEWORK_NAME='PXCTestKit.framework'
BUILT_FRAMEWORK_PATH="$NEW_RELEASE_DIR/Frameworks/$BUILT_FRAMEWORK_NAME"
LICENSE_NAME='LICENSE'
LICENSE_PATH="./$LICENSE_NAME"

echo "Building to $NEW_RELEASE_DIR"

./scripts/build.sh "$NEW_RELEASE_DIR"

echo "Creating portable release"

PORTABLE_RELEASE_DIR="$NEW_RELEASE_DIR/portable_pxctest"

mkdir -p "$PORTABLE_RELEASE_DIR"

cp -f "$BUILT_BIN_PATH" "$PORTABLE_RELEASE_DIR"
cp -fR "$BUILT_FRAMEWORK_PATH" "$PORTABLE_RELEASE_DIR"
cp -f "$LICENSE_PATH" "$PORTABLE_RELEASE_DIR"

(cd "$PORTABLE_RELEASE_DIR"; zip -yr - "$BUILT_BIN_NAME" "$BUILT_FRAMEWORK_NAME" "$LICENSE_NAME") > "$PORTABLE_RELEASE_DIR.zip"

echo "Tagging release"

git commit -a -m "release $NEW_VERSION"
git tag -a "$NEW_VERSION" -m "release $NEW_VERSION"
git push origin master
git push origin "$NEW_VERSION"

echo "Release complete; see https://github.com/plu/pxctest#release-version-update for next steps."
