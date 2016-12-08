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

    enum RuntimeError: Error {
        case testRunHadFailures(Int)
        case testRunHadErrors([TestError])
    }

    struct TestError {
        let simulator: FBSimulator
        let target: String
        let errors: [Error]
        let crashes: [FBDiagnostic]
    }

    private let context: Context
    private let reporterRegistry: ReporterRegistry
    private var simulators: [FBSimulator] = []
    private var testRun: FBXCTestRun!

    init(context: Context) {
        self.context = context
        self.reporterRegistry = ReporterRegistry(context: context)
    }

    func abort() {
        for simulator in simulators {
            for application in testRun.targets.flatMap({ $0.applications }) {
                do {
                    try simulator.killApplication(withBundleID: application.bundleID)
                }
                catch {
                    context.consoleOutput.write(line: "\(error)")
                }
            }
        }
        context.consoleOutput.write(line: "\n\(ANSI.red)Test run was aborted\(ANSI.reset)")
    }

    func run() throws {
        try run(control: FBSimulatorControl.withContext(context))
    }

    func run(control: FBSimulatorControl) throws {
        testRun = try FBXCTestRun.withTestRunFile(atPath: context.testRun.path).build()

        try context.output.reset(
            targets: testRun.targets.map({ $0.name }),
            simulatorConfigurations: context.simulatorConfigurations
        )

        simulators = try context.simulatorConfigurations.map {
            try control.pool.allocateSimulator(with: $0, options: context.simulatorAllocationOptions)
        }

        try simulators.loadDefaults(context: context)
        try simulators.boot(context: context)

        let testErrors = try test(simulators: simulators, testRun: testRun)
        try context.output.extractDiagnostics(simulators: simulators, testRun: testRun, testErrors: testErrors)

        if testErrors.count > 0 {
            throw RuntimeError.testRunHadErrors(testErrors)
        }

        writeConsoleOutputSummary()

        let failureCount = reporterRegistry.summary.reduce(0) { $0 + $1.total.failureCount }
        if failureCount > 0 {
            throw RuntimeError.testRunHadFailures(failureCount)
        }
    }

    // MARK: - Private

    private func test(simulators: [FBSimulator], testRun: FBXCTestRun) throws -> [TestError] {
        var errors: [TestError] = []

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

            try simulators.install(applications: target.applications)

            for simulator in simulators {
                try simulator.interact
                    .startTest(
                        with: testLaunchConfigurartion,
                        reporter: try reporterRegistry.addReporter(for: simulator, target: target)
                    )
                    .perform()
            }

            for simulator in simulators {
                let testManagerResults = simulator.resourceSink.testManagers.flatMap { $0.waitUntilTestingHasFinished(withTimeout: context.timeout) }
                if testManagerResults.reduce(true, { $0 && $1.didEndSuccessfully }) {
                    continue
                }
                let error = TestError(
                    simulator: simulator,
                    target: target.name,
                    errors: testManagerResults.flatMap { $0.error },
                    crashes: testManagerResults.flatMap { $0.crashDiagnostic }
                )
                errors.append(error)
            }
        }

        return errors
    }

    private func writeConsoleOutputSummary() {
        let console = context.consoleOutput
        let writeTotalSummary = reporterRegistry.console.reduce(true, { return $0 && $1.writeTotalSummary })

        if writeTotalSummary {
            console.write(line: "")
        }

        reporterRegistry.console.forEach { $0.writeFailures() }
        reporterRegistry.console.forEach { $0.writeSummary() }

        if writeTotalSummary {
            let runCount = reporterRegistry.summary.reduce(0) { $0 + $1.total.runCount }
            let failureCount = reporterRegistry.summary.reduce(0) { $0 + $1.total.failureCount }
            let unexpected = reporterRegistry.summary.reduce(0) { $0 + $1.total.unexpected }
            let output = String(format: "\(ANSI.bold)Total - Finished executing %d tests. %d Failures, %d Unexpected\(ANSI.reset)", runCount, failureCount, unexpected)
            console.write(line: output)
        }
    }

}
