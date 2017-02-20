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
        case testRunEmpty
    }

    private let context: Context
    private let reporters: RunTestsReporters
    private var workers: [RunTestsWorker] = []

    init(context: Context) {
        self.context = context
        self.reporters = RunTestsReporters(context: ReporterContext(context: context))
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
        try run(control: FBSimulatorControl.withContext(ControlContext(context: context)))
    }

    func run(control: FBSimulatorControl) throws {
        let targets = try FBXCTestRun.withTestRunFile(atPath: context.testRun.path).build().targets
        let pool = RunTestsPool(context: AllocationContext(context: context), pool: control.pool, targets: targets)

        workers = try pool.allocateWorkers()

        try workers.loadDefaults(context: DefaultsContext(context: context))
        try workers.overrideWatchDogTimer()
        try workers.boot(context: BootContext(context: context))
        try workers.installApplications()
        try workers.startTests(context: RunTestsContext(context: context), reporters: reporters)

        let testErrors = try workers.waitForTestResult(context: TestResultContext(context: context))
        try reporters.finishReporting(testErrors: testErrors, consoleOutput: context.consoleOutput)
    }

}
