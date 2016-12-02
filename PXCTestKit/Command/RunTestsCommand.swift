//
//  RunTestsCommand.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsCommand: Command {

    enum RunTestsError: Error, CustomStringConvertible {
        case testRunHadFailures(Int)

        var description: String {
            switch self {
            case .testRunHadFailures(let count): return "Test run had \(count) failures"
            }
        }
    }

    struct Context {
        let testRun: URL
        let deviceSet: URL
        let output: URL
        let locale: Locale
        let environment: [String: String]
        let preferences: [String: Any]
        let reporterType: ConsoleReporter.Type
        let testsToRun: [String: Set<String>]
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

    private let context: Context
    private var reporters = Reporters()
    private var simulators: [FBSimulator] = []
    private var testRun: FBXCTestRun!

    internal var control: FBSimulatorControl!

    init(context: Context) {
        self.context = context
    }

    func abort() {
        for simulator in simulators {
            for target in testRun.targets {
                for application in target.applications {
                    do {
                        try simulator.killApplication(withBundleID: application.bundleID)
                    }
                    catch {
                        // Ignore
                    }
                }
            }
        }
        context.consoleOutput.write(line: "\n\(ANSI.red)Test run was aborted\(ANSI.reset)")
    }

    func run() throws {
        testRun = try FBXCTestRun.withTestRunFile(atPath: context.testRun.path).build()

        try resetOutput(testRun: testRun)

        let logFileHandle = try FileHandle(forWritingTo: context.logFileURL())
        control = try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorManagementOptions),
            logger: FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: logFileHandle.fileDescriptor, withDebugLogging: false)
        )

        simulators = try context.simulators.map {
            try control.pool.allocateSimulator(with: $0, options: context.simulatorAllocationOptions)
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

        if !fileManager.fileExists(atPath: context.output.path) {
            try fileManager.createDirectory(at: context.output, withIntermediateDirectories: true, attributes: nil)
        }

        if fileManager.fileExists(atPath: context.logFileURL().path) {
            try fileManager.removeItem(at: context.logFileURL())
        }

        fileManager.createFile(atPath: context.logFileURL().path, contents: nil, attributes: nil)

        for target in testRun.targets {
            for simulatorConfiguration in context.simulators {
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
            .withLocalizationOverride(FBLocalizationOverride.withLocale(context.locale))
            .withOptions(context.simulatorBootOptions)

        for simulator in simulators {
            if simulator.state == .booted {
                continue
            }
            try simulator.interact
                .editPropertyListFileRelative(fromRootPath: "Library/Preferences/com.apple.Preferences.plist") {
                    $0.addEntries(from: self.context.preferences)
                }
                .prepare(forBoot: simulatorBootConfiguration)
                .bootSimulator(simulatorBootConfiguration)
                .perform()
        }
    }

    private func test(simulators: [FBSimulator], testRun: FBXCTestRun) throws {
        for target in testRun.targets {
            if context.testsToRun.count > 0 && context.testsToRun[target.name] == nil {
                continue
            }

            var testsToRun = target.testLaunchConfiguration.testsToRun
            if context.testsToRun.count > 0, let targetTestsToRun = context.testsToRun[target.name] {
                testsToRun = target.testLaunchConfiguration.testsToRun.union(targetTestsToRun)
            }
            let testEnvironment = Environment.prepare(target.testLaunchConfiguration.testEnvironment, with: context.environment)
            let testLaunchConfigurartion = target.testLaunchConfiguration
                .withTestsToRun(testsToRun)
                .withTestEnvironment(testEnvironment)

            for simulator in simulators {
                for application in target.applications {
                    try simulator.interact
                        .installApplication(application)
                        .perform()
                }

                try simulator.interact
                    .startTest(
                        with: testLaunchConfigurartion,
                        reporter: reporter(for: simulator, target: target)
                    )
                    .perform()
            }

            for simulator in simulators {
                try simulator.interact
                    .waitUntilAllTestRunnersHaveFinishedTesting(withTimeout: context.timeout)
                    .perform()
            }
        }
    }

    private func reporter(for simulator: FBSimulator, target: FBXCTestRunTarget) -> FBTestManagerTestReporter {
        let simulatorIdentifier = "\(simulator.configuration!.deviceName) \(simulator.configuration!.osVersionString)"
        let consoleReporter = context.reporterType.init(simulatorIdentifier: simulatorIdentifier, testTargetName: target.name, consoleOutput: context.consoleOutput)
        let junitReportURL = outputURL(for: simulator.configuration!, target: target).appendingPathComponent("junit.xml")
        let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(junitReportURL)
        let xcodeReportURL = outputURL(for: simulator.configuration!, target: target).appendingPathComponent("test.log")
        let xcodeReporter = XcodeReporter(fileURL: xcodeReportURL)
        let summaryReporter = SummaryReporter()

        reporters.console.append(consoleReporter)
        reporters.summary.append(summaryReporter)

        return FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, junitReporter, summaryReporter, xcodeReporter])
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
        let console = context.consoleOutput
        let writeTotalSummary = reporters.console.reduce(true, { return $0 && $1.writeTotalSummary })

        if writeTotalSummary {
            console.write(line: "")
        }

        reporters.console.forEach { $0.writeFailures() }
        reporters.console.forEach { $0.writeSummary() }

        if writeTotalSummary {
            let runCount = reporters.summary.reduce(0) { $0 + $1.total.runCount }
            let failureCount = reporters.summary.reduce(0) { $0 + $1.total.failureCount }
            let unexpected = reporters.summary.reduce(0) { $0 + $1.total.unexpected }
            let output = String(format: "\(ANSI.bold)Total - Finished executing %d tests. %d Failures, %d Unexpected\(ANSI.reset)", runCount, failureCount, unexpected)
            console.write(line: output)
        }
    }

    private func outputURL(for simulatorConfiguration: FBSimulatorConfiguration, target: FBXCTestRunTarget) -> URL {
        return context.output
            .appendingPathComponent(target.name)
            .appendingPathComponent(simulatorConfiguration.osVersionString)
            .appendingPathComponent(simulatorConfiguration.deviceName)
    }

}
