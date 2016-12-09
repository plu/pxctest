//
//  ConsoleReporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

protocol ConsoleReporter: FBTestManagerTestReporter {

    var console: ConsoleOutput { get }
    var simulatorIdentifier: String { get }
    var summary: FBTestManagerResultSummary? { get }
    var testTargetName: String { get }

    init(simulatorIdentifier: String, testTargetName: String, consoleOutput: ConsoleOutput)

    static func finishReporting(reporters: [ConsoleReporter]) throws

}

extension ConsoleReporter {

    static func raiseTestRunHadFailures(reporters: [ConsoleReporter]) throws {
        let totalFailures = reporters.reduce(0) { $0 + ($1.summary?.failureCount ?? 1) }
        if totalFailures > 0 {
            throw RunTestsCommand.RuntimeError.testRunHadFailures(totalFailures)
        }
    }

}
