//
//  RunTestsSimulator.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsSimulator {

    let simulator: FBSimulator
    let target: FBXCTestRunTarget

    init(simulator: FBSimulator, target: FBXCTestRunTarget) {
        self.simulator = simulator
        self.target = target
    }

    func abortTestRun() throws {
        for application in target.applications {
            try simulator.killApplication(withBundleID: application.bundleID)
        }
    }

    func boot(context: BootContext) throws {
        try simulator.boot(context: context)
    }

    func loadDefaults(context: DefaultsContext) throws {
        try simulator.loadDefaults(context: context)
    }

    func installApplications() throws {
        try simulator.install(applications: target.applications)
    }

    func overrideWatchDogTimer() throws {
        try simulator.overrideWatchDogTimer(targets: [target])
    }

    func startTests(context: RunTestsContext, reporters: RunTestsReporters) throws {
        let testsToRun = context.testsToRun[target.name] ?? Set<String>()
        let testEnvironment = Environment.prepare(forRunningTests: target.testLaunchConfiguration.testEnvironment, with: context.environment)
        let testLaunchConfigurartion = target.testLaunchConfiguration
            .withTestsToRun(target.testLaunchConfiguration.testsToRun.union(testsToRun))
            .withTestEnvironment(testEnvironment)

        let reporter = try reporters.addReporter(for: simulator, target: target)

        try simulator.interact.startTest(with: testLaunchConfigurartion, reporter: reporter).perform()
    }

    func waitUntilTestingHasFinished(timeout: TimeInterval) -> RunTestsError? {
        let testManagerResults = simulator.resourceSink.testManagers.flatMap { $0.waitUntilTestingHasFinished(withTimeout: timeout) }
        if testManagerResults.reduce(true, { $0 && $1.didEndSuccessfully }) {
            return nil
        }
        return RunTestsError(
            simulator: simulator,
            target: target.name,
            errors: testManagerResults.flatMap { $0.error },
            crashes: testManagerResults.flatMap { $0.crashDiagnostic }
        )
    }

}

extension Sequence where Iterator.Element == RunTestsSimulator {

    func abortTestRun() throws {
        for simulator in self {
            try simulator.abortTestRun()
        }
    }

    func boot(context: BootContext) throws {
        for simulator in self {
            try simulator.boot(context: context)
        }
    }

    func installApplications() throws {
        for simulator in self {
            try simulator.installApplications()
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for simulator in self {
            try simulator.loadDefaults(context: context)
        }
    }

    func overrideWatchDogTimer() throws {
        for simulator in self {
            try simulator.overrideWatchDogTimer()
        }
    }

    func startTests(context: RunTestsContext, reporters: RunTestsReporters) throws {
        for simulator in self {
            try simulator.startTests(context: context, reporters: reporters)
        }
    }

    func waitUntilTestingHasFinished(timeout: TimeInterval) -> [RunTestsError] {
        return flatMap { $0.waitUntilTestingHasFinished(timeout: timeout) }
    }

}
