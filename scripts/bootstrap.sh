#!/usr/bin/env bash

set -e

pushd Dependencies/Commander
xcrun swift package generate-xcodeproj --output ../
popd
