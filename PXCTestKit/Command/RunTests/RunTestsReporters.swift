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
    private var consoleReporters: [ConsoleReporter] = []
    private var testReporters: [TestReporter] = []

    init(context: ReporterContext) {
        consoleOutput = context.consoleOutput
        fileManager = context.fileManager
        reporterType = context.reporterType
    }

    func addReporter(for simulator: FBSimulator, name: String, testTargetName: String) throws -> FBTestManagerTestReporter {
        // `name` might be equal to `testTargetName`, unless tests are partitioned, then `name` is something like "testTargetName/partition-n"
        let consoleReporter = reporterType.init(simulatorIdentifier: simulator.identifier, testTargetName: name, consoleOutput: consoleOutput)
        let xcodeReportURL = fileManager.urlFor(simulatorConfiguration: simulator.configuration!, target: name).appendingPathComponent("test.log")
        let xcodeReporter = try XcodeReporter(simulatorIdentifier: simulator.identifier, testTargetName: name, fileURL: xcodeReportURL)
        let testReporter = TestReporter(simulatorIdentifier: simulator.identifier, testTargetName: name)

        consoleReporters.append(consoleReporter)
        testReporters.append(testReporter)

        return TestReporterAdapter(reporters: [consoleReporter, testReporter, xcodeReporter])
    }

    func finishReporting(consoleOutput: ConsoleOutput) throws {
        try writeRuntimeCache() // FIXME: Error handling
        try writeJUnitReport()  // FIXME: Error handling
        try reporterType.finishReporting(consoleOutput: consoleOutput, reporters: consoleReporters)
    }

    // MARK: - Private

    private func writeRuntimeCache() throws {
        try JSONSerialization
            .data(withJSONObject: testReporters.runtimeRecords.map({ $0.asDictionary }), options: [])
            .write(to: fileManager.runtimeCacheURL)
    }

    private func writeJUnitReport() throws {
        var testSuites: [FBTestManagerTestReporterTestSuite] = []
        for testReporter in testReporters {
            guard let testReporterTestSuite = testReporter.testSuite else { continue }
            let targetTestSuite = FBTestManagerTestReporterTestSuite.withName(testReporter.testTargetName, startTime: "\(Date())")
            let simulatorTestSuite = FBTestManagerTestReporterTestSuite.withName(testReporter.simulatorIdentifier, startTime: "\(Date())")
            testSuites.append(targetTestSuite)
            targetTestSuite.addTestSuite(simulatorTestSuite)
            simulatorTestSuite.addTestSuite(testReporterTestSuite)
        }
        let document = FBTestManagerJUnitGenerator.document(for: testSuites)
        try document.xmlData(withOptions: 0).write(to: fileManager.outputURL.appendingPathComponent("junit.xml"))
    }

}
