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

    enum RunTestsError: Error {
        case testRunHadFailures(Int)
    }

    struct Configuration {
        let testRun: URL
        let deviceSet: URL
        let output: URL
        let locale: Locale
        let preferences: [String: Any]
        let testsToRun: Set<String>
        let simulators: [FBSimulatorConfiguration]
        let timeout: Double

        func logFileURL() -> URL {
            return output.appendingPathComponent("simulator.log")
        }
    }

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func run() throws {
        let testRun = try FBXCTestRun.withTestRunFile(atPath: configuration.testRun.path).build()

        try resetOutput(testRun: testRun)

        let logFileHandle = try FileHandle(forWritingTo: configuration.logFileURL())
        let control = try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: configuration.deviceSet.path, options: []),
            logger: FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: logFileHandle.fileDescriptor, withDebugLogging: false)
        )

        let simulators = try configuration.simulators.map {
            try control.pool.allocateSimulator(with: $0, options: [.create, .reuse])
        }

        try boot(simulators: simulators)
        try test(simulators: simulators, testRun: testRun)
        try extractDiagnostics(simulators: simulators, testRun: testRun)

        ConsoleReporter.writeSummary()

        if SummaryReporter.total.failureCount > 0 {
            throw RunTestsError.testRunHadFailures(SummaryReporter.total.failureCount)
        }
    }

    // MARK: - Private

    private func resetOutput(testRun: FBXCTestRun) throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: configuration.output.path) {
            try fileManager.removeItem(at: configuration.output)
        }

        try fileManager.createDirectory(at: configuration.output, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFile(atPath: configuration.logFileURL().path, contents: nil, attributes: nil)

        for target in testRun.targets {
            for simulatorConfiguration in configuration.simulators {
                let url = outputURL(for: simulatorConfiguration, target: target)
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
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

    private func test(simulators: [FBSimulator], testRun: FBXCTestRun) throws {
        for target in testRun.targets {
            var testEnvironment = target.testLaunchConfiguration.testEnvironment ?? [:]
            testEnvironment["OS_ACTIVITY_MODE"] = "disable"
            let testsToRun = target.testLaunchConfiguration.testsToRun.union(configuration.testsToRun)
            let testLaunchConfigurartion = target.testLaunchConfiguration
                .withTestsToRun(testsToRun)
                .withTestEnvironment(testEnvironment)

            for simulator in simulators {
                let simulatorIdentifier = "\(simulator.configuration!.deviceName) \(simulator.configuration!.osVersionString)"
                let consoleReporter = ConsoleReporter(simulatorIdentifier: simulatorIdentifier, testTargetName: target.name)
                let junitReportURL = outputURL(for: simulator.configuration!, target: target)
                let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(junitReportURL.appendingPathComponent("junit.xml"))

                for application in target.applications {
                    try simulator.interact
                        .installApplication(application)
                        .perform()
                }

                try simulator.interact
                    .startTest(
                        with: testLaunchConfigurartion,
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
    }

    private func extractDiagnostics(simulators: [FBSimulator], testRun: FBXCTestRun) throws {
        for simulator in simulators {
            for target in testRun.targets {
                for application in target.applications {
                    guard let diagnostics = simulator.diagnostics.launchedProcessLogs().first(where: { $0.0.processName == application.name })?.value else { continue }
                    guard let logFilePath = diagnostics.asPath else { return }
                    let destinationPath = outputURL(for: simulator.configuration!, target: target).appendingPathComponent("\(application.name).log").path
                    try FileManager.default.copyItem(atPath: logFilePath, toPath: destinationPath)
                }
            }
        }
    }

    private func outputURL(for simulatorConfiguration: FBSimulatorConfiguration, target: FBXCTestRunTarget) -> URL {
        return configuration.output
            .appendingPathComponent(target.name)
            .appendingPathComponent(simulatorConfiguration.osVersionString)
            .appendingPathComponent(simulatorConfiguration.deviceName)
    }

}
