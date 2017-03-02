//
//  ListTestsCommand.swift
//  pxctest
//
//  Created by Johannes Plunien on 10/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class ListTestsCommand: Command {

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func abort() {
    }

    func run() throws {
        let fileDescriptor = FileHandle.nullDevice.fileDescriptor // FIXME
        let control = try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorOptions.managementOptions),
            logger: FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: fileDescriptor, withDebugLogging: false)
        )
        try run(control: control)
    }

    func run(control: FBSimulatorControl) throws {
        let listTestsShimPath = try ListTestsShim.copy()
        let testRun = try FBXCTestRun.withTestRunFile(atPath: context.testRun.path).build()
        let simulator = try control.pool.allocateSimulator(with: context.simulatorConfiguration, options: context.simulatorOptions.allocationOptions)
        let simulatorBootConfiguration = FBSimulatorBootConfiguration.withOptions(context.simulatorOptions.bootOptions)

        if simulator.state != .booted {
            try simulator.bootSimulator(simulatorBootConfiguration)
        }

        for target in testRun.targets {
            let environment = Environment.injectLibrary(atPath: listTestsShimPath, into: target.testLaunchConfiguration.testEnvironment)
            let testLaunchConfiguration = target.testLaunchConfiguration.withTestEnvironment(environment)
            let reporter = TestReporterAdapter(reporter: JSONReporter(simulatorIdentifier: simulator.identifier, testTargetName: target.name, consoleOutput: context.consoleOutput))

            try simulator.install(applications: target.applications)
            try simulator.startTest(with: testLaunchConfiguration, reporter: reporter)
            try simulator.waitUntilAllTestRunnersHaveFinishedTesting(withTimeout: context.timeout)
        }
    }

}
