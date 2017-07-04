#!/usr/bin/env bash

set -e

PXCTEST_PLIST='pxctest/info.plist'
NEW_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PXCTEST_PLIST")

echo "$NEW_VERSION"
