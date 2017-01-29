//
//  TestReporterInterface.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

protocol TestReporterInterface {

    func didBeginExecutingTestPlan()
    func testSuiteDidStart(testSuite: String, startTime: String)
    func testCaseDidStart(testClass: String, method: String)
    func testCaseDidFail(testClass: String, method: String, message: String, file: String!, line: UInt)
    func testCaseDidFinish(testClass: String, method: String, status: FBTestReportStatus, duration: TimeInterval)
    func testSuiteDidFinish(summary: FBTestManagerResultSummary)
    func didFinishExecutingTestPlan()

}
