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
    var testTargetName: String { get }

    init(simulatorIdentifier: String, testTargetName: String, consoleOutput: ConsoleOutput)

    func writeFailures()
    func writeSummary()

}
