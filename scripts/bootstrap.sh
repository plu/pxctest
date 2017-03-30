#!/usr/bin/env bash

set -e

pushd Dependencies/Commander
xcrun swift package fetch
popd

git checkout -f HEAD Dependencies/Commander.xcodeproj*
