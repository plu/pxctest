//
//  XcodeReporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 02/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class XcodeReporter: NSObject, FBTestManagerTestReporter {

    private let fileURL: URL
    private var output = Data()

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    private func write(_ string: String) {
        guard let data = "\(string)\n".data(using: .utf8) else { return }
        output.append(data)
    }

    // MARK: - FBTestManagerTestReporter

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testSuite: String!, didStartAt startTime: String!) {
        write(String(
            format: "Test Suite '%@' started at %@",
            testSuite!, startTime!
        ))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidStartForTestClass testClass: String!, method: String!) {
        write(String(
            format: "Test Case '-[%@ %@]' started.",
            testClass!, method!
        ))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFinishForTestClass testClass: String!, method: String!, with status: FBTestReportStatus, duration: TimeInterval) {
        write(String(
            format: "Test Case '-[%@ %@]' %@ (%.03f seconds).",
            testClass!, method!, FBTestManagerResultSummary.statusString(for: status).lowercased(), duration
        ))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFailForTestClass testClass: String!, method: String!, withMessage message: String!, file: String!, line: UInt) {
        write(String(
            format: "%@:%d: error: -[%@ %@] : %@",
            file!, line, testClass!, method!, message!
        ))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, finishedWith summary: FBTestManagerResultSummary!) {
        let testSuiteResult = summary.failureCount > 0 ? "failed" : "passed"
        write(String(
            format: "Test Suite '%@' %@ at %@.",
            summary.testSuite, testSuiteResult, summary.finishTime
        ))
        write(String(
            format: "      Executed %@, with %@ (%d unexpected) in %.03fs (%.03fs) seconds",
            summary.runCount.forOutput("test"),
            summary.failureCount.forOutput("failure"),
            summary.unexpected,
            summary.testDuration,
            summary.totalDuration
        ))
    }

    func testManagerMediatorDidFinishExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        do {
            try output.write(to: fileURL)
        }
        catch {
            // FIXME: Handle error
        }
    }

    func testManagerMediatorDidBeginExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testBundleReadyWithProtocolVersion protocolVersion: Int, minimumVersion: Int) {
    }

}

extension Int {

    func forOutput(_ string: String) -> String {
        return self == 1 ? "\(self) \(string)" : "\(self) \(string)s"
    }

}
