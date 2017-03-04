//
//  RunTestsPool.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/01/17.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsPool {

    private let context: AllocationContext
    private let pool: FBSimulatorPool
    private let targets: [FBXCTestRunTarget]
    private var workers: [RunTestsWorker] = []

    init(context: AllocationContext, pool: FBSimulatorPool, targets: [FBXCTestRunTarget]) {
        self.context = context
        self.pool = pool
        self.targets = targets
    }

    func allocateWorkers() throws -> [RunTestsWorker] {
        for target in targets {
            if context.testsToRun.count > 0 && context.testsToRun[target.name] == nil {
                continue
            }
            for simulatorConfiguration in context.simulatorConfigurations {
                try allocateWorkers(simulatorConfiguration: simulatorConfiguration, target: target)
            }
        }
        return workers
    }

    // MARK: - Private

    private func allocateWorkers(simulatorConfiguration: FBSimulatorConfiguration, target: FBXCTestRunTarget) throws {
        if context.partitions == 1 {
            try context.fileManager.createDirectoryFor(simulatorConfiguration: simulatorConfiguration, target: target.name)
            let simulator = try pool.allocateSimulator(with: simulatorConfiguration, options: context.simulatorOptions.allocationOptions)
            let worker = RunTestsWorker(
                name: target.name,
                applications: target.applications,
                simulator: simulator,
                targetName: target.name,
                testLaunchConfiguration: target.testLaunchConfiguration
            )
            workers.append(worker)
        }
        else {
            let simulators = try (0..<context.partitions).map { _ in try pool.allocateSimulator(with: simulatorConfiguration, options: context.simulatorOptions.allocationOptions) }
            let tests = try listTests(simulator: simulators.first!, target: target)
            let partitionManager = RunTestsPartitionManager(fileURL: context.fileManager.runtimeCacheURL, partitions: context.partitions, targetName: target.name)
            for (index, subsetOfTests) in partitionManager.split(tests: tests).enumerated() {
                let partitionName = "\(target.name)/partition-\(index)"
                try context.fileManager.createDirectoryFor(simulatorConfiguration: simulatorConfiguration, target: partitionName)
                let worker = RunTestsWorker(
                    name: partitionName,
                    applications: target.applications,
                    simulator: simulators[index],
                    targetName: target.name,
                    testLaunchConfiguration: target.testLaunchConfiguration.withTestsToRun(Set(subsetOfTests.map { $0.testName }))
                )
                workers.append(worker)
            }
        }
    }

    private func listTests(simulator: FBSimulator, target: FBXCTestRunTarget) throws -> Set<String> {
        let listTestsShimPath = try ListTestsShim.copy()
        let testsToRun = context.testsToRun[target.name] ?? Set<String>()
        let environment = Environment.injectLibrary(atPath: listTestsShimPath, into: target.testLaunchConfiguration.testEnvironment)
        let testLaunchConfiguration = target.testLaunchConfiguration
            .withTestEnvironment(environment)
            .withTestsToRun(testsToRun.union(target.testLaunchConfiguration.testsToRun ?? Set<String>()))
        let reporter = TestReporter(simulatorIdentifier: simulator.identifier, testTargetName: target.name)
        let adapter = TestReporterAdapter(reporter: reporter)
        try simulator.install(applications: target.applications)
        try simulator.startTest(with: testLaunchConfiguration, reporter: adapter)
        try simulator.waitUntilAllTestRunnersHaveFinishedTesting(withTimeout: 120.0)
        return Set(reporter.runtimeRecords.map({ $0.testName })).subtracting(target.testLaunchConfiguration.testsToSkip)
    }

}
