# pxctest

Execute tests in parallel on multiple iOS Simulators.

[![Build Status](https://travis-ci.org/plu/pxctest.svg?branch=master)](https://travis-ci.org/plu/pxctest)

![screencast](static/screencast.gif?raw=true "screencast")

## Installation

To install via Homebrew you can use the [plu/homebrew-pxctest](https://github.com/plu/homebrew-pxctest) tap:

```shell
brew tap plu/pxctest
brew install pxctest
```

## Usage

Compile your tests with `build-for-testing`, example:

```shell
xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath="$PWD/build/Products" \
  -scheme 'MyApp' \
  -workspace 'MyApp.xcworkspace' \
  -destination 'platform=iOS Simulator,name=iPhone 5,OS=10.1' \
  build-for-testing
```

In `build/Products` you should find a `.xctestrun` file. This can then be passed to `pxctest`:

```shell
pxctest \
  run-tests \
  --destination 'name=iPhone 5,os=iOS 9.3' \
  --destination 'name=iPhone 5,os=iOS 10.1' \
  --testrun build/Products/MyApp_iphonesimulator10.1-i386.xctestrun
```

The `--destination` option can be passed in several times and will execute the tests in parallel on all Simulators.

### run-tests options

To see a list of possible options, just run:

```shell
pxctest run-tests --help
```

Most of the options should be self-explanatory. If not, please open an issue or submit some pull request. However the `--preferences` option needs a special section here.

#### run-tests --preferences

This option expects a path to a file, which contains some JSON. After loading this file, its content gets applied to the Simulator's preferences property list file located at `Library/Preferences/com.apple.Preferences.plist`.

Example: You can turn off all keyboard settings that you can find in the Simulator's Settings app by using following JSON content:

```json
{
  "com.apple.Preferences": {
    "KeyboardAllowPaddle": false,
    "KeyboardAssistant": false,
    "KeyboardAutocapitalization": false,
    "KeyboardAutocorrection": false,
    "KeyboardCapsLock": false,
    "KeyboardCheckSpelling": false,
    "KeyboardPeriodShortcut": false,
    "KeyboardPrediction": false,
    "KeyboardShowPredictionBar": false
  }
}
```

## Development

```shell
git clone --recursive https://github.com/plu/pxctest.git pxctest
cd pxctest
scripts/bootstrap.sh
NSUnbufferedIO=YES xcodebuild -scheme pxctest test | xcpretty -c
```

## FBSimulatorControl

The functionality of `pxctest` would not be possible without the
great [FBSimulatorControl Framework](https://github.com/facebook/FBSimulatorControl)
provided by [Lawrence Lomax](https://github.com/lawrencelomax) at
[Facebook](https://github.com/facebook).

There are two command line tools that come with [FBSimulatorControl](https://github.com/facebook/FBSimulatorControl):

* [fbsimctl](https://github.com/facebook/FBSimulatorControl/tree/master/fbsimctl) - command line interface to the FBSimulatorControl Framework
* [fbxctest](https://github.com/facebook/FBSimulatorControl/tree/master/fbxctest) - test runner for running iOS testing bundles for the iOS Simulator Platform

Both of them are more flexible than `pxctest`, so it might be worth having a look at them.

## License

[MIT](LICENSE)
