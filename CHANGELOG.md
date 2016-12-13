* Block assertions in release builds
* Fix writing simulator.log
* Add --debug flag
* Uninstall application before test run
* Override watchdog timeout to 60s

# 0.2.9

* Send user notifications about test results
* Show commit in version output

# 0.2.8

* Extract crash logs
* Breaking change: --preferences was renamed to --defaults. Also the JSON format changed

# 0.2.7

* Support abort via SIGINT
* Support JSON stream reporter (similar to xctool's JSON stream)
* Breaking change: --only expects a new format: TARGET[:Class/case[,Class2/case2]]
* Write test log file in format similar to Xcode

# 0.2.6

* Fix crash on Jenkins caused by `synchronizeFile`
* Support --no-color command line option

# 0.2.5

* Inject PXCTEST_CHILD_ prefixed environment variables

# 0.2.4

* Add some integration tests
* Support multiple test targets

# 0.2.3

* Add JUnit report
* Extract application logs
* Write test reports and log files to output/

# 0.2.2

* Fix duplicate symbols when installed via Homebrew

# 0.2.1

* Fix duplicate symbols due to wrong run path

# 0.2.0

* Support --locale command line option
* Support --preferences command line option
* Support --only command line option

# 0.1.0

* Initial release.
