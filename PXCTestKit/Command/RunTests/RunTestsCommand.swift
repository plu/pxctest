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
    private var workers: [RunTestsWorker] = []

    init(context: Context) {
        self.context = context
        self.reporters = RunTestsReporters(context: context)
    }

    func abort() {
        do {
            try workers.abortTestRun()
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

        workers = try control.pool.allocate(context: context, targets: testRun.targets)

        try workers.loadDefaults(context: context)
        try workers.overrideWatchDogTimer()
        try workers.boot(context: context)
        try workers.installApplications()
        try workers.startTests(context: context, reporters: reporters)

        let testErrors = try workers.waitForTestResult(context: context)
        if testErrors.count > 0 {
            throw RuntimeError.testRunHadErrors(testErrors)
        }

        try reporters.finishReporting(consoleOutput: context.consoleOutput)
    }

}
