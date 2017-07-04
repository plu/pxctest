#!/usr/bin/env bash

set -e

brew update && brew bump-formula-pr --tag=$(shell git describe --tags) --revision=$(shell git rev-parse HEAD) pxctest
pod trunk push pxctest.podspec
