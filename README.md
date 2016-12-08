# pxctest

Execute tests in parallel on multiple iOS Simulators.

[![Build Status](https://travis-ci.org/plu/pxctest.svg?branch=master)](https://travis-ci.org/plu/pxctest)

![screencast](static/screencast.gif?raw=true "screencast")

## Installation

To install via Homebrew you can use the [plu/homebrew-pxctest](https://github.com/plu/homebrew-pxctest) tap:

```shell
$ brew tap plu/pxctest && brew install pxctest
```

## Usage

Compile your tests with `build-for-testing`, example:

```shell
$ xcodebuild \
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
$ pxctest \
    run-tests \
    --destination 'name=iPhone 5,os=iOS 9.3' \
    --destination 'name=iPhone 5,os=iOS 10.1' \
    --testrun build/Products/MyApp_iphonesimulator10.1-i386.xctestrun
```

The `--destination` option can be passed in several times and will execute the tests in parallel on all Simulators.

### run-tests options

To see a list of possible options, just run:

```shell
$ pxctest run-tests --help
```

Most of the options should be self-explanatory. If not, please open an issue or submit some pull request. However the `--defaults` option needs a special section here.

#### run-tests --defaults

This option expects a path to a file, which contains some JSON. After loading this file, its content gets applied to the Simulator's defaults. On the top level the keys must be either a relative path or a domain where the defaults are located.

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

### Headless testing

It's possible to execute the tests without actually launching a `Simulator.app` window. This can be convenient because it will separate your test workflow from your development. If the tests run in the `Simulator.app` window and you launch your app during the test run from Xcode, it will stop the tests. There's not much we can do about that, it's just the way Xcode is handling `Simulator.app` - it takes control over all instances.

First you need to pre-boot some Simulators in the background, with a custom device set path:

```shell
$ mkdir /tmp/test-simulators
$ xcrun simctl --set /tmp/test-simulators create 'iPhone 5' 'iPhone 5' com.apple.CoreSimulator.SimRuntime.iOS-9-3
716A9864-08BD-4200-96ED-20EA1E81BE65
$ xcrun simctl --set /tmp/test-simulators create 'iPad Retina' 'iPad Retina' com.apple.CoreSimulator.SimRuntime.iOS-9-3
D2EB2BB9-8862-4F0D-A933-079C9BA0342A
$ xcrun simctl --set /tmp/test-simulators boot 716A9864-08BD-4200-96ED-20EA1E81BE65
$ xcrun simctl --set /tmp/test-simulators boot D2EB2BB9-8862-4F0D-A933-079C9BA0342A
```

Booting the Simulators in a usable state can take some time. Since they don't have a window, we cannot see the loading indicator on top of the Springboard to identifiy if they are ready or not. So just give them some time to finish booting before you make your first test run.

To launch your tests on these Simulators, you just need to pass the `--deviceset` option to `pxctest`:

```shell
$ pxctest run-tests \
    --testrun build/Products/KIF_iphonesimulator10.1-i386.xctestrun \
    --deviceset /tmp/test-simulators \
    --destination 'name=iPhone 5,os=iOS 9.3' \
    --destination 'name=iPad Retina,os=iOS 9.3' \
    --only 'KIF Tests:TappingTests'
....................
KIF Tests - iPhone 5 iOS 9.3 - Finished executing 10 tests after 25.252s. 0 Failures, 0 Unexpected
KIF Tests - iPad Retina iOS 9.3 - Finished executing 10 tests after 25.119s. 0 Failures, 0 Unexpected
Total - Finished executing 20 tests. 0 Failures, 0 Unexpected
```

If you still see some `Simulator.app` window showing up, it might have different reasons:

* something went wrong pre-booting the devices earlier
* you forgot the `--deviceset` option
* you didn't pre-boot all devices that you're using as `--destination` options now

You can verify the state of your devices via:

```shell
$ xcrun simctl --set /tmp/test-simulators list
== Devices ==
-- iOS 9.3 --
    iPhone 5 (716A9864-08BD-4200-96ED-20EA1E81BE65) (Booted)
    iPad Retina (D2EB2BB9-8862-4F0D-A933-079C9BA0342A) (Booted)
```

The `Booted` state here however does not mean "is ready for launching apps or running tests". After booting a device it enters the `Booted` state quickly, but still showing the loading bar above the Springboard (you can see that if you boot them via `Simulator.app` and keep watching the state that `xcrun simctl` reports).

Here you can see that the tests are running, but no `Simulator.app` window is visible:

![headless_screencast](static/headless_screencast.gif?raw=true "headless screencast")

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

## Resource limits

By default the resource limitations (maximum processes per user, maximum open files) on Mac OS are quite small. There even seems to be a hard limit baked into the kernel of 2500 maximum processes per user. But there's some boot arguments that can be set to raise this limit to at least 5000.

So why is this important? A booted iPhone 7 Simulator is not just one process, it comes with a whole set of running processes. If you boot a couple Simulators at the same time, add your other running programs/processes on top of that, then you will hit these limits soon.

First we [set the nvram boot argument](https://support.apple.com/en-ae/HT202528):

```shell
$ sudo nvram boot-args="serverperfmode=1 $(nvram boot-args 2>/dev/null | cut -f 2-)"
```

Next step is to make `launchd` set the new limits:

```shell
$ sudo cp config/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
$ sudo cp config/limit.maxproc.plist /Library/LaunchDaemons/limit.maxproc.plist
```

The two files can be found in this repository:

* [limit.maxfiles.plist](config/limit.maxfiles.plist)
* [limit.maxproc.plist](config/limit.maxproc.plist)

And we reboot! Afterwards you can check:

```shell
$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
file size               (blocks, -f) unlimited
max locked memory       (kbytes, -l) unlimited
max memory size         (kbytes, -m) unlimited
open files                      (-n) 524288
pipe size            (512 bytes, -p) 1
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 5000
virtual memory          (kbytes, -v) unlimited
```

The `open files` part should say `524288`, and `max user processes` should be `5000`.

## License

[MIT](LICENSE)
