//
//  TestReporterAdapter.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class TestReporterAdapter: NSObject {

    fileprivate let reporters: [TestReporterInterface]

    convenience init(reporter: TestReporterInterface) {
        self.init(reporters: [reporter])
    }

    init(reporters: [TestReporterInterface]) {
        self.reporters = reporters
    }

}

extension TestReporterAdapter: FBTestManagerTestReporter {

    func testManagerMediatorDidBeginExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        reporters.forEach { $0.didBeginExecutingTestPlan() }
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testSuite: String!, didStartAt startTime: String!) {
        reporters.forEach { $0.testSuiteDidStart(testSuite: testSuite, startTime: startTime) }
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFinishForTestClass testClass: String!, method: String!, with status: FBTestReportStatus, duration: TimeInterval) {
        reporters.forEach { $0.testCaseDidFinish(testClass: testClass, method: method, status: status, duration: duration) }
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFailForTestClass testClass: String!, method: String!, withMessage message: String!, file: String!, line: UInt) {
        reporters.forEach { $0.testCaseDidFail(testClass: testClass, method: method, message: message, file: file, line: line) }
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidStartForTestClass testClass: String!, method: String!) {
        reporters.forEach { $0.testCaseDidStart(testClass: testClass, method: method) }
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, finishedWith summary: FBTestManagerResultSummary!) {
        reporters.forEach { $0.testSuiteDidFinish(summary: summary) }
    }

    func testManagerMediatorDidFinishExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        reporters.forEach { $0.didFinishExecutingTestPlan() }
    }

    // MARK: - Unused

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testBundleReadyWithProtocolVersion protocolVersion: Int, minimumVersion: Int) {
    }

}
