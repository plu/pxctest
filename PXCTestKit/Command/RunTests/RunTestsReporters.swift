//
//  RunTestsReporters.swift
//  pxctest
//
//  Created by Johannes Plunien on 8/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsReporters {

    private let consoleOutput: ConsoleOutput
    private let fileManager: RunTestsFileManager
    private let reporterType: ConsoleReporter.Type
    private var reporters: [ConsoleReporter] = []

    init(context: ReporterContext) {
        consoleOutput = context.consoleOutput
        fileManager = context.fileManager
        reporterType = context.reporterType
    }

    func addReporter(for simulator: FBSimulator, target: FBXCTestRunTarget) throws -> FBTestManagerTestReporter {
        let consoleReporter = reporterType.init(simulatorIdentifier: simulator.identifier, testTargetName: target.name, consoleOutput: consoleOutput)
        let junitReportURL = fileManager.urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).appendingPathComponent("junit.xml")
        let junitReporter = FBTestManagerTestReporterJUnit.withOutputFileURL(junitReportURL)
        let xcodeReportURL = fileManager.urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).appendingPathComponent("test.log")
        let xcodeReporter = try XcodeReporter(fileURL: xcodeReportURL)

        reporters.append(consoleReporter)

        return FBTestManagerTestReporterComposite.withTestReporters([consoleReporter, junitReporter, xcodeReporter])
    }

    func finishReporting(consoleOutput: ConsoleOutput) throws {
        try reporterType.finishReporting(consoleOutput: consoleOutput, reporters: reporters)
    }

}
