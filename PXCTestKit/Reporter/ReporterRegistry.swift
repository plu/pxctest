//
//  ReporterRegistry.swift
//  pxctest
//
//  Created by Johannes Plunien on 8/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class ReporterRegistry {

    private let context: ReporterContext

    init(context: ReporterContext) {
        self.context = context
    }

    private(set) var console: [ConsoleReporter] = []
    private(set) var summary: [SummaryReporter] = []

    func addReporter(for simulator: FBSimulator, target: FBXCTestRunTarget) throws -> FBTestManagerTestReporter {
        let simulatorIdentifier = "\(simulator.configuration!.deviceName) \(simulator.configuration!.osVersionString)"
        let consoleReporter = context.reporterType.init(simulatorIdentifier: simulatorIdentifier, testTargetName: target.name, consoleOutput: context.consoleOutput)
        let junitReportURL = context.output.urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).appendingPathComponent("junit.xml")
        let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(junitReportURL)
        let xcodeReportURL = context.output.urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).appendingPathComponent("test.log")
        let xcodeReporter = try XcodeReporter(fileURL: xcodeReportURL)
        let summaryReporter = SummaryReporter()

        console.append(consoleReporter)
        summary.append(summaryReporter)

        return FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, junitReporter, summaryReporter, xcodeReporter])
    }

}
