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
    private var reporters: [ConsoleReporter] = []

    init(context: ReporterContext) {
        self.context = context
    }

    func addReporter(for simulator: FBSimulator, target: FBXCTestRunTarget) throws -> FBTestManagerTestReporter {
        let simulatorIdentifier = "\(simulator.configuration!.deviceName) \(simulator.configuration!.osVersionString)"
        let consoleReporter = context.reporterType.init(simulatorIdentifier: simulatorIdentifier, testTargetName: target.name, consoleOutput: context.consoleOutput)
        let junitReportURL = context.output.urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).appendingPathComponent("junit.xml")
        let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(junitReportURL)
        let xcodeReportURL = context.output.urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).appendingPathComponent("test.log")
        let xcodeReporter = try XcodeReporter(fileURL: xcodeReportURL)

        reporters.append(consoleReporter)

        return FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, junitReporter, xcodeReporter])
    }

    func finishReporting() throws {
        try context.reporterType.finishReporting(reporters: reporters)
    }

}
