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
        let testReporter = TestReporter(simulatorIdentifier: simulator.identifier, testTargetName: name)

        consoleReporters.append(consoleReporter)
        testReporters.append(testReporter)

        return TestReporterAdapter(reporters: [consoleReporter, testReporter])
    }

    func finishReporting(testErrors: [RunTestsError], consoleOutput: ConsoleOutput) throws {
        if testErrors.count > 0 {
            throw RunTestsCommand.RuntimeError.testRunHadErrors(testErrors)
        }

        try writeRuntimeCache() // FIXME: Error handling
        try writeJUnitReport()  // FIXME: Error handling
        try reporterType.finishReporting(consoleOutput: consoleOutput, reporters: consoleReporters)

        let runCount = testReporters.reduce(0) { $0 + ($1.testSuite?.summary?.runCount ?? 0) }
        if runCount == 0 {
            throw RunTestsCommand.RuntimeError.testRunEmpty
        }
    }

    // MARK: - Private

    private func writeRuntimeCache() throws {
        try JSONSerialization
            .data(withJSONObject: testReporters.runtimeRecords.map({ $0.asDictionary }), options: [])
            .write(to: fileManager.runtimeCacheURL)
    }

    private func writeJUnitReport() throws {
        var testSuiteElements: [XMLElement] = []
        for testReporter in testReporters {
            guard let testSuite = testReporter.testSuite else { continue }
            testSuiteElements.append(FBTestManagerJUnitGenerator.element(for: testSuite, packagePrefix: testReporter.simulatorIdentifier))
        }
        guard testSuiteElements.count > 0 else { return }
        let document = FBTestManagerJUnitGenerator.document(forTestSuiteElements: testSuiteElements)
        try document.xmlData(withOptions: 0).write(to: fileManager.outputURL.appendingPathComponent("junit.xml"))
    }

}
