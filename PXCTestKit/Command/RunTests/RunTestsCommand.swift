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
        case testRunHadErrors([RunTestsError])
    }

    private let context: Context
    private let reporters: RunTestsReporters
    private var simulators: [RunTestsSimulator] = []

    init(context: Context) {
        self.context = context
        self.reporters = RunTestsReporters(context: context)
    }

    func abort() {
        do {
            try simulators.abortTestRun()
        }
        catch {
            context.consoleOutput.write(line: "\(error)")
        }
        context.consoleOutput.write(line: "\(ANSI.red)Test run was aborted\(ANSI.reset)")
    }

    func run() throws {
        try run(control: FBSimulatorControl.withContext(context))
    }

    func run(control: FBSimulatorControl) throws {
        let testRun = try FBXCTestRun.withTestRunFile(atPath: context.testRun.path).build()

        try context.outputManager.reset(
            targets: testRun.targets.map({ $0.name }),
            simulatorConfigurations: context.simulatorConfigurations
        )

        simulators = try control.pool.allocate(context: context, targets: testRun.targets)

        try simulators.loadDefaults(context: context)
        try simulators.overrideWatchDogTimer()
        try simulators.boot(context: context)
        try simulators.installApplications()
        try simulators.startTests(context: context, reporters: reporters)

        let testErrors = try simulators.waitForTestResult(context: context)
        if testErrors.count > 0 {
            throw RuntimeError.testRunHadErrors(testErrors)
        }

        try reporters.finishReporting(consoleOutput: context.consoleOutput)
    }

}
