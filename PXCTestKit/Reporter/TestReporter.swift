//
//  TestReporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

class TestReporter: TestReporterInterface {

    let simulatorIdentifier: String
    let testTargetName: String

    init(simulatorIdentifier: String, testTargetName: String) {
        self.simulatorIdentifier = simulatorIdentifier
        self.testTargetName = testTargetName
    }

    var runtimeRecords: Set<TestRuntimeRecord> {
        return Set(allTestCases(of: testSuite).map({ TestRuntimeRecord(testName: "\($0.testClass)/\($0.method)", targetName: testTargetName, runtime: $0.duration) }))
    }

    func didBeginExecutingTestPlan() {}

    func testSuiteDidStart(testSuite: String, startTime: String) {
        let testSuite = FBTestManagerTestReporterTestSuite.withName(testSuite, startTime: startTime)

        if let currentTestSuite = currentTestSuite {
            currentTestSuite.addTestSuite(testSuite)
        }
        else {
            self.testSuite = testSuite
        }

        self.currentTestSuite = testSuite
    }

    func testCaseDidStart(testClass: String, method: String) {
        let testCase = FBTestManagerTestReporterTestCase.withTestClass(testClass, method: method)
        currentTestCase = testCase
        currentTestSuite?.addTestCase(testCase)
    }

    func testCaseDidFail(testClass: String, method: String, message: String, file: String!, line: UInt) {
        currentTestCase?.addFailure(FBTestManagerTestReporterTestCaseFailure.withMessage(message, file: file, line: line))
    }

    func testCaseDidFinish(testClass: String, method: String, status: FBTestReportStatus, duration: TimeInterval) {
        assert(currentTestCase?.testClass == testClass && currentTestCase?.method == method)
        currentTestCase?.finish(with: status, duration: duration)
        currentTestCase = nil
    }

    func testSuiteDidFinish(summary: FBTestManagerResultSummary) {
        assert(currentTestSuite!.name == summary.testSuite)

        currentTestSuite?.finish(with: summary)
        if let parentTestSuite = currentTestSuite?.parent {
            currentTestSuite = parentTestSuite
        }
    }

    func didFinishExecutingTestPlan() {}

    // MARK: - Private

    private(set) var testSuite: FBTestManagerTestReporterTestSuite?

    private var currentTestCase: FBTestManagerTestReporterTestCase?
    private var currentTestSuite: FBTestManagerTestReporterTestSuite?


    private func allTestCases(of testSuite: FBTestManagerTestReporterTestSuite?) -> [FBTestManagerTestReporterTestCase] {
        var tests: [FBTestManagerTestReporterTestCase] = []
        guard let testSuite = testSuite else { return tests }
        for testCase in testSuite.testCases {
            tests.append(testCase)
        }
        for testSuite in testSuite.testSuites {
            tests.append(contentsOf: allTestCases(of: testSuite))
        }
        return tests
    }

}

extension Sequence where Iterator.Element == TestReporter {

    var runtimeRecords: Set<TestRuntimeRecord> {
        return reduce(Set<TestRuntimeRecord>()) { $0.0.union($0.1.runtimeRecords) }
    }

}
