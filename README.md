# pxctest

Parallel XCTest - Execute XCTest suites in parallel on multiple iOS Simulators.

## Usage

Compile your tests with `build-for-testing`, example:

```
xcodebuild \
  -IDEBuildLocationStyle=Custom \
  -IDECustomBuildLocationType=Absolute \
  -IDECustomBuildProductsPath="$PWD/build/Products" \
  -scheme 'MyApp' \
  -workspace 'MyApp.xcworkspace' \
  -destination 'platform=iOS Simulator,name=iPhone 5,OS=9.3' \
  build-for-testing
```

In `build/Products` you should find a `.xctestrun` file. This can then be passed to `pxctest`:

```
pxctest \
  run-tests \
  --destination 'name=iPhone 5,os=iOS 9.3' \
  --destination 'name=iPhone 5,os=iOS 10.1' \
  --testrun build/Products/MyApp_iphonesimulator10.1-i386.xctestrun
```

The `--destination` option can be passed in several times and will execute the tests in parallel on all Simulators.

## FBSimulatorControl

The functionality provided by `pxctest` would not be possible without the
great [FBSimulatorControl Framework](https://github.com/facebook/FBSimulatorControl)
provided by [Lawrence Lomax](https://github.com/lawrencelomax) at
[Facebook](https://github.com/facebook).

There are two command line tools that come with [FBSimulatorControl](https://github.com/facebook/FBSimulatorControl):

* [fbsimctl](https://github.com/facebook/FBSimulatorControl/tree/master/fbsimctl) - command line interface to the FBSimulatorControl Framework
* [fbxctest](https://github.com/facebook/FBSimulatorControl/tree/master/fbxctest) - test runner for running iOS testing bundles for the iOS Simulator Platform

Both of them are more flexible than `pxctest`, so it might be worth having a look at them.

## License

[BSD-licensed](LICENSE)
