//
//  XcodeReporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 02/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class XcodeReporter: TestReporter {

    private let fileHandle: FileHandle

    init(simulatorIdentifier: String, testTargetName: String, fileURL: URL) throws {
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        self.fileHandle = try FileHandle(forWritingTo: fileURL)
        super.init(simulatorIdentifier: simulatorIdentifier, testTargetName: testTargetName)
    }

    private func write(_ string: String) {
        guard let data = "\(string)\n".data(using: .utf8) else { return }
        fileHandle.write(data)
    }

    // MARK: - TestReporter

    override func testSuiteDidStart(testSuite: String, startTime: String) {
        super.testSuiteDidStart(testSuite: testSuite, startTime: startTime)

        write(String(
            format: "Test Suite '%@' started at %@",
            testSuite, startTime
        ))
    }

    override func testCaseDidStart(testClass: String, method: String) {
        super.testCaseDidStart(testClass: testClass, method: method)

        write(String(
            format: "Test Case '-[%@ %@]' started.",
            testClass, method
        ))
    }

    override func testCaseDidFinish(testClass: String, method: String, status: FBTestReportStatus, duration: TimeInterval) {
        super.testCaseDidFinish(testClass: testClass, method: method, status: status, duration: duration)

        write(String(
            format: "Test Case '-[%@ %@]' %@ (%.03f seconds).",
            testClass, method, FBTestManagerResultSummary.statusString(for: status).lowercased(), duration
        ))
    }

    override func testCaseDidFail(testClass: String, method: String, message: String, file: String!, line: UInt) {
        super.testCaseDidFail(testClass: testClass, method: method, message: message, file: file, line: line)

        write(String(
            format: "%@:%d: error: -[%@ %@] : %@",
            file!, line, testClass, method, message
        ))
    }

    override func testSuiteDidFinish(summary: FBTestManagerResultSummary) {
        super.testSuiteDidFinish(summary: summary)

        let testSuiteResult = summary.failureCount > 0 ? "failed" : "passed"

        write(String(
            format: "Test Suite '%@' %@ at %@.",
            summary.testSuite, testSuiteResult, summary.finishTime.description
        ))

        write(String(
            format: "      Executed %@, with %@ (%d unexpected) in %.03fs (%.03fs) seconds",
            summary.runCount.pluralized("test"),
            summary.failureCount.pluralized("failure"),
            summary.unexpected,
            summary.testDuration,
            summary.totalDuration
        ))
    }

}
