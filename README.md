# pxctest

Parallel XCTest - Execute XCTest suites in parallel on multiple iOS Simulators.

## Description

TBD.

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
