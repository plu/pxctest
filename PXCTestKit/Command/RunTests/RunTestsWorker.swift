//
//  RunTestsWorker.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsWorker {

    let simulator: FBSimulator
    let target: FBXCTestRunTarget

    var configuration: FBSimulatorConfiguration {
        return simulator.configuration!
    }

    private(set) var errors: [RunTestsError] = []

    init(simulator: FBSimulator, target: FBXCTestRunTarget) {
        self.simulator = simulator
        self.target = target
    }

    func abortTestRun() throws {
        for application in target.applications {
            try simulator.killApplication(withBundleID: application.bundleID)
        }
    }

    func extractDiagnostics(outputManager: RunTestsOutputManager) throws {
        for application in target.applications {
            guard let diagnostics = simulator.simulatorDiagnostics.launchedProcessLogs().first(where: { $0.0.processName == application.name })?.value else { continue }
            let destinationPath = outputManager.urlFor(worker: self).path
            try diagnostics.writeOut(toDirectory: destinationPath)
        }
        for error in errors {
            for crash in error.crashes {
                let destinationPath = outputManager.urlFor(worker: self).path
                try crash.writeOut(toDirectory: destinationPath)
            }
        }
    }

    func startTests(context: RunTestsContext, reporters: RunTestsReporters) throws {
        let testsToRun = context.testsToRun[target.name] ?? Set<String>()
        let testEnvironment = Environment.injectPrefixedVariables(from: context.environment, into: target.testLaunchConfiguration.testEnvironment)
        let testLaunchConfigurartion = target.testLaunchConfiguration
            .withTestsToRun(target.testLaunchConfiguration.testsToRun.union(testsToRun))
            .withTestEnvironment(testEnvironment)

        let reporter = try reporters.addReporter(for: simulator, target: target)

        try simulator.interact.startTest(with: testLaunchConfigurartion, reporter: reporter).perform()
    }

    func waitForTestResult(timeout: TimeInterval) {
        let testManagerResults = simulator.resourceSink.testManagers.flatMap { $0.waitUntilTestingHasFinished(withTimeout: timeout) }
        if testManagerResults.reduce(true, { $0 && $1.didEndSuccessfully }) {
            return
        }
        errors.append(
            RunTestsError(
                simulator: simulator,
                target: target.name,
                errors: testManagerResults.flatMap { $0.error },
                crashes: testManagerResults.flatMap { $0.crashDiagnostic }
            )
        )
    }

}

extension Sequence where Iterator.Element == RunTestsWorker {

    func abortTestRun() throws {
        for worker in self {
            try worker.abortTestRun()
        }
    }

    func boot(context: BootContext) throws {
        for worker in self {
            guard worker.simulator.state != .booted else { continue }
            try worker.simulator.interact.boot(context: context).perform()
        }
    }

    func installApplications() throws {
        for worker in self {
            try worker.simulator.reinstall(applications: worker.target.applications)
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for worker in self {
            try worker.simulator.interact.loadDefaults(context: context).perform()
        }
    }

    func overrideWatchDogTimer() throws {
        for worker in self {
            let applications = worker.target.applications.map { $0.bundleID }
            try worker.simulator.interact.overrideWatchDogTimer(forApplications: applications, withTimeout: 60.0).perform()
        }
    }

    func startTests(context: RunTestsContext, reporters: RunTestsReporters) throws {
        for worker in self {
            try worker.startTests(context: context, reporters: reporters)
        }
    }

    func waitForTestResult(context: TestResultContext) throws -> [RunTestsError] {
        for worker in self {
            worker.waitForTestResult(timeout: context.timeout)
        }

        for worker in self {
            try worker.extractDiagnostics(outputManager: context.outputManager)
        }

        return flatMap { $0.errors }
    }

}
