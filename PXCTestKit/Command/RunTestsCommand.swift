//
//  RunTestsCommand.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsCommand {

    struct Configuration {
        let testRun: URL
        let deviceSet: URL
        let locale: Locale
        let preferences: [String: Any]
        let testsToRun: Set<String>
        let simulators: [FBSimulatorConfiguration]
        let timeout: Double
    }

    private let configuration: Configuration

    private var application: FBApplicationDescriptor!
    private var testRun: FBXCTestRun!

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func run() throws {
        try XCTestBootstrapFrameworkLoader.loadPrivateFrameworks(nil)

        testRun = try FBXCTestRun.withTestRunFile(atPath: configuration.testRun.path).build()
        application = try FBApplicationDescriptor.application(withPath: testRun.testHostPath)

        // FIXME: Redirect logs to file, not /dev/null.
        let logger = FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: FileHandle.nullDevice.fileDescriptor, withDebugLogging: false)
        let simulatorControlConfiguration = FBSimulatorControlConfiguration(deviceSetPath: configuration.deviceSet.path, options: [])
        let control = try FBSimulatorControl.withConfiguration(simulatorControlConfiguration, logger: logger)

        let simulators = try configuration.simulators.map {
            try control.pool.allocateSimulator(with: $0, options: [.create, .reuse])
        }

        try boot(simulators: simulators)
        try test(simulators: simulators)

        ConsoleReporter.writeSummary()

        if SummaryReporter.total.failureCount > 0 {
            exit(1)
        }
    }

    // MARK: - Private

    private func boot(simulators: [FBSimulator]) throws {
        let simulatorBootConfiguration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(configuration.locale))

        for simulator in simulators {
            if simulator.state == .booted {
                continue
            }
            try simulator.interact
                .editPropertyListFileRelative(fromRootPath: "Library/Preferences/com.apple.Preferences.plist") {
                    $0.addEntries(from: self.configuration.preferences)
                }
                .prepare(forBoot: simulatorBootConfiguration)
                .bootSimulator(simulatorBootConfiguration)
                .perform()
        }
    }

    private func test(simulators: [FBSimulator]) throws {
        let applicationLaunchConfiguration = FBApplicationLaunchConfiguration(
            application: application,
            arguments: testRun.arguments,
            environment: testRun.environment,
            options: []
        )

        let testLaunchConfiguration = FBTestLaunchConfiguration(testBundlePath: testRun.testBundlePath)
            .withApplicationLaunchConfiguration(applicationLaunchConfiguration)
            .withTimeout(configuration.timeout)
            .withTestsToSkip(testRun.testsToSkip)
            .withTestsToRun(testRun.testsToRun.union(configuration.testsToRun))

        for simulator in simulators {
            let simulatorIdentifier = "\(simulator.deviceConfiguration.deviceName) (\(simulator.osConfiguration.name))"
            let consoleReporter = ConsoleReporter(simulatorIdentifier: simulatorIdentifier)
            try simulator.interact
                .installApplication(application)
                .startTest(
                    with: testLaunchConfiguration,
                    reporter: FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, SummaryReporter()])
                )
                .perform()
        }

        for simulator in simulators {
            try simulator.interact
                .waitUntilAllTestRunnersHaveFinishedTesting(withTimeout: configuration.timeout)
                .perform()
        }
    }

}
