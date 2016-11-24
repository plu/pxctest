//
//  StandardOutputReporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class StandardOutputReporter: FBTestManagerTestReporterBase {

    private let simulatorIdentifier: String

    init(simulatorIdentifier: String) {
        self.simulatorIdentifier = simulatorIdentifier
    }

    static func writeSummary(reporters: [StandardOutputReporter]) {
        guard let writer = reporters.first else { return }
        writer.write(line: "\nFinished.")
        reporters.forEach { $0.writeFailures() }
        reporters.forEach { $0.writeSummary() }
        let total = SummaryReporter.total
        let output = String(format: "Total - Finished executing %d tests. %d Failures, %d Unexpected\n", total.runCount, total.failureCount, total.unexpected)
        writer.write(output: output)
    }

    private func writeSummary() {
        guard let summary = testSuite.summary else { return }

        let output = String(format: "\(simulatorIdentifier) - Finished executing %d tests after %.03fs. %d Failures, %d Unexpected\n", summary.runCount, summary.totalDuration, summary.failureCount, summary.unexpected)
        write(output: output)
    }

    override func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFinishForTestClass testClass: String!, method: String!, with status: FBTestReportStatus, duration: TimeInterval) {
        switch status {
        case .unknown:
            write(output: "?")
        case .passed:
            write(output: ".")
        case .failed:
            write(output: "F")
        }

        super.testManagerMediator(mediator, testCaseDidFinishForTestClass: testClass, method: method, with: status, duration: duration)
    }

    // MARK: - Private

    private func writeFailures() {
        guard let summary = testSuite.summary else { return }

        if summary.failureCount > 0 {
            write(line: simulatorIdentifier)
            write(line: "`- Failures:")
            writeFailures(testSuite: testSuite)
        }
    }

    private func writeFailures(testSuite: FBTestManagerTestReporterTestSuite) {
        for testCase in testSuite.testCases {
            guard testCase.failures.count > 0 else { continue }
            write(line: "  `- -[\(testCase.testClass) \(testCase.method)]")
            for failure in testCase.failures {
                let filename = URL(fileURLWithPath: failure.file).lastPathComponent
                write(line: "    `- \(filename):\(failure.line) \(failure.message)")
            }
        }
        for testSuite in testSuite.testSuites {
            writeFailures(testSuite: testSuite)
        }
    }

    private func write(line: String) {
        write(output: "\(line)\n")
    }

    private func write(output: String) {
        let fileHandle = FileHandle.standardOutput
        fileHandle.write(output.data(using: .utf8)!)
        fileHandle.synchronizeFile()
    }

}
