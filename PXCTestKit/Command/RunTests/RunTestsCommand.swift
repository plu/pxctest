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

        workers = try RunTestsWorker.allocate(pool: control.pool, context: AllocationContext(context: context), targets: targets)

        try workers.loadDefaults(context: DefaultsContext(context: context))
        try workers.overrideWatchDogTimer()
        try workers.boot(context: BootContext(context: context))
        try workers.installApplications()
        try workers.startTests(context: RunTestsContext(context: context), reporters: reporters)

        let testErrors = try workers.waitForTestResult(context: TestResultContext(context: context))
        if testErrors.count > 0 {
            throw RuntimeError.testRunHadErrors(testErrors)
        }

        try reporters.finishReporting(consoleOutput: context.consoleOutput)
    }

}
