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
        let output: URL
        let locale: Locale
        let preferences: [String: Any]
        let testsToRun: Set<String>
        let simulators: [FBSimulatorConfiguration]
        let timeout: Double
    }

    private let configuration: Configuration
    private let logFileURL: URL

    private var application: FBApplicationDescriptor!
    private var testRun: FBXCTestRun!

    init(configuration: Configuration) {
        self.configuration = configuration
        self.logFileURL = configuration.output.appendingPathComponent("simulator.log")
    }

    func run() throws {
        try XCTestBootstrapFrameworkLoader.loadPrivateFrameworks(nil)

        try resetOutput()

        testRun = try FBXCTestRun.withTestRunFile(atPath: configuration.testRun.path).build()
        application = try FBApplicationDescriptor.application(withPath: testRun.testHostPath)

        let logFileHandle = try FileHandle(forWritingTo: logFileURL)
        let logger = FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: logFileHandle.fileDescriptor, withDebugLogging: false)
        let simulatorControlConfiguration = FBSimulatorControlConfiguration(deviceSetPath: configuration.deviceSet.path, options: [])
        let control = try FBSimulatorControl.withConfiguration(simulatorControlConfiguration, logger: logger)

        let simulators = try configuration.simulators.map {
            try control.pool.allocateSimulator(with: $0, options: [.create, .reuse])
        }

        try boot(simulators: simulators)
        try test(simulators: simulators)
        try extractDiagnostics(simulators: simulators)

        ConsoleReporter.writeSummary()

        if SummaryReporter.total.failureCount > 0 {
            exit(1)
        }
    }

    // MARK: - Private

    private func resetOutput() throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: configuration.output.path) {
            try fileManager.removeItem(at: configuration.output)
        }

        try fileManager.createDirectory(at: configuration.output, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)

        for simulatorConfiguration in configuration.simulators {
            try fileManager.createDirectory(at: outputURL(simulatorConfiguration: simulatorConfiguration), withIntermediateDirectories: true, attributes: nil)
        }
    }

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
        var environment = testRun.environment
        // Make Xcode output less noisy
        environment["OS_ACTIVITY_MODE"] = "disable"

        let applicationLaunchConfiguration = FBApplicationLaunchConfiguration(
            application: application,
            arguments: testRun.arguments,
            environment: environment,
            options: []
        )

        let testLaunchConfiguration = FBTestLaunchConfiguration(testBundlePath: testRun.testBundlePath)
            .withApplicationLaunchConfiguration(applicationLaunchConfiguration)
            .withTimeout(configuration.timeout)
            .withTestsToSkip(testRun.testsToSkip)
            .withTestsToRun(testRun.testsToRun.union(configuration.testsToRun))

        for simulator in simulators {
            let simulatorConfiguration = simulator.configuration!
            let consoleReporter = ConsoleReporter(simulatorIdentifier: identifier(simulatorConfiguration: simulatorConfiguration))
            let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(outputURL(simulatorConfiguration: simulatorConfiguration).appendingPathComponent("junit.xml"))
            try simulator.interact
                .installApplication(application)
                .startTest(
                    with: testLaunchConfiguration,
                    reporter: FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, junitReporter, SummaryReporter()])
                )
                .perform()
        }

        for simulator in simulators {
            try simulator.interact
                .waitUntilAllTestRunnersHaveFinishedTesting(withTimeout: configuration.timeout)
                .perform()
        }
    }

    private func extractDiagnostics(simulators: [FBSimulator]) throws {
        for simulator in simulators {
            guard let diagnostics = simulator.diagnostics.launchedProcessLogs().first(where: { $0.0.processName == application.name })?.value else { continue }
            guard let logFilePath = diagnostics.asPath else { return }
            let destinationPath = outputURL(simulatorConfiguration: simulator.configuration!).appendingPathComponent("\(application.name).log").path
            try FileManager.default.copyItem(atPath: logFilePath, toPath: destinationPath)
        }
    }

    private func outputURL(simulatorConfiguration: FBSimulatorConfiguration) -> URL {
        return configuration.output.appendingPathComponent(identifier(simulatorConfiguration: simulatorConfiguration))
    }

    private func identifier(simulatorConfiguration: FBSimulatorConfiguration) -> String {
        return "\(simulatorConfiguration.deviceName) - \(simulatorConfiguration.osVersionString)"
    }

}
