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

    enum RunTestsError: Error, CustomStringConvertible {
        case testRunHadFailures(Int)

        var description: String {
            switch self {
            case .testRunHadFailures(let count): return "Test run had \(count) failures"
            }
        }
    }

    struct Configuration {
        let testRun: URL
        let deviceSet: URL
        let output: URL
        let locale: Locale
        let environment: [String: String]
        let preferences: [String: Any]
        let testsToRun: Set<String>
        let simulators: [FBSimulatorConfiguration]
        let timeout: Double
        let consoleOutput: ConsoleOutput
        let simulatorManagementOptions: FBSimulatorManagementOptions
        let simulatorAllocationOptions: FBSimulatorAllocationOptions
        let simulatorBootOptions: FBSimulatorBootOptions

        func logFileURL() -> URL {
            return output.appendingPathComponent("simulator.log")
        }
    }

    struct Reporters {
        var console: [ConsoleReporter] = []
        var summary: [SummaryReporter] = []
    }

    private let configuration: Configuration
    private var reporters = Reporters()
    internal var control: FBSimulatorControl!

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func run() throws {
        let testRun = try FBXCTestRun.withTestRunFile(atPath: configuration.testRun.path).build()

        try resetOutput(testRun: testRun)

        let logFileHandle = try FileHandle(forWritingTo: configuration.logFileURL())
        control = try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: configuration.deviceSet.path, options: configuration.simulatorManagementOptions),
            logger: FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: logFileHandle.fileDescriptor, withDebugLogging: false)
        )

        let simulators = try configuration.simulators.map {
            try control.pool.allocateSimulator(with: $0, options: configuration.simulatorAllocationOptions)
        }

        try boot(simulators: simulators)
        try test(simulators: simulators, testRun: testRun)
        try extractDiagnostics(simulators: simulators, testRun: testRun)

        writeConsoleOutputSummary()

        let failureCount = reporters.summary.reduce(0) { $0 + $1.total.failureCount }
        if failureCount > 0 {
            throw RunTestsError.testRunHadFailures(failureCount)
        }
    }

    // MARK: - Private

    private func resetOutput(testRun: FBXCTestRun) throws {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: configuration.output.path) {
            try fileManager.createDirectory(at: configuration.output, withIntermediateDirectories: true, attributes: nil)
        }

        if fileManager.fileExists(atPath: configuration.logFileURL().path) {
            try fileManager.removeItem(at: configuration.logFileURL())
        }

        fileManager.createFile(atPath: configuration.logFileURL().path, contents: nil, attributes: nil)

        for target in testRun.targets {
            for simulatorConfiguration in configuration.simulators {
                let url = outputURL(for: simulatorConfiguration, target: target)
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                }
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }

    private func boot(simulators: [FBSimulator]) throws {
        let simulatorBootConfiguration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(configuration.locale))
            .withOptions(configuration.simulatorBootOptions)

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
            let testEnvironment = Environment.prepare(target.testLaunchConfiguration.testEnvironment, with: configuration.environment)
            let testsToRun = target.testLaunchConfiguration.testsToRun.union(configuration.testsToRun)
            let testLaunchConfigurartion = target.testLaunchConfiguration
                .withTestsToRun(testsToRun)
                .withTestEnvironment(testEnvironment)

            for simulator in simulators {
                let simulatorIdentifier = "\(simulator.configuration!.deviceName) \(simulator.configuration!.osVersionString)"
                let consoleReporter = ConsoleReporter(simulatorIdentifier: simulatorIdentifier, testTargetName: target.name, consoleOutput: configuration.consoleOutput)
                let junitReportURL = outputURL(for: simulator.configuration!, target: target)
                let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(junitReportURL.appendingPathComponent("junit.xml"))
                let summaryReporter = SummaryReporter()

                reporters.console.append(consoleReporter)
                reporters.summary.append(summaryReporter)

                for application in target.applications {
                    try simulator.interact
                        .installApplication(application)
                        .perform()
                }

                try simulator.interact
                    .startTest(
                        with: testLaunchConfigurartion,
                        reporter: FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, junitReporter, summaryReporter])
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

    private func writeConsoleOutputSummary() {
        let consoleOutput = configuration.consoleOutput
        consoleOutput.write(line: "")
        reporters.console.forEach { $0.writeFailures() }
        reporters.console.forEach { $0.writeSummary() }

        let runCount = reporters.summary.reduce(0) { $0 + $1.total.runCount }
        let failureCount = reporters.summary.reduce(0) { $0 + $1.total.failureCount }
        let unexpected = reporters.summary.reduce(0) { $0 + $1.total.unexpected }
        let output = String(format: "\(ANSI.bold)Total - Finished executing %d tests. %d Failures, %d Unexpected\(ANSI.reset)", runCount, failureCount, unexpected)
        consoleOutput.write(line: output)
    }

    private func outputURL(for simulatorConfiguration: FBSimulatorConfiguration, target: FBXCTestRunTarget) -> URL {
        return configuration.output
            .appendingPathComponent(target.name)
            .appendingPathComponent(simulatorConfiguration.osVersionString)
            .appendingPathComponent(simulatorConfiguration.deviceName)
    }

}
