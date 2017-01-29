//
//  TestReporterTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 28/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class TestReporterTests: XCTestCase {

    func testReportersWithSameTarget() {
        let reporters = [
            TestReporter(simulatorIdentifier: "iPhone 5 10.2", testTargetName: "UITests"),
            TestReporter(simulatorIdentifier: "iPhone 5 10.2", testTargetName: "UITests"),
        ]
        reporters.forEach {
            $0.testSuiteDidStart(testSuite: "All Tests", startTime: "")
            $0.testCaseDidStart(testClass: "TestCaseOne", method: "testThis")
            $0.testCaseDidFinish(testClass: "TestCaseOne", method: "testThis", status: .passed, duration: 0.123)
            $0.testCaseDidStart(testClass: "TestCaseTwo", method: "testThat")
            $0.testCaseDidFinish(testClass: "TestCaseTwo", method: "testThat", status: .passed, duration: 0.456)
        }
        XCTAssertEqual(
            reporters.runtimeRecords,
            Set([TestRuntimeRecord(testName: "TestCaseOne/testThis", targetName: "UITests", runtime: 0.123),
                 TestRuntimeRecord(testName: "TestCaseTwo/testThat", targetName: "UITests", runtime: 0.456)])
        )
    }

    func testReportersWithDifferentTargets() {
        let reporters = [
            TestReporter(simulatorIdentifier: "iPhone 5 10.2", testTargetName: "UITests"),
            TestReporter(simulatorIdentifier: "iPhone 5 10.2", testTargetName: "UnitTests"),
        ]
        reporters.forEach {
            $0.testSuiteDidStart(testSuite: "All Tests", startTime: "")
            $0.testCaseDidStart(testClass: "TestCaseOne", method: "testThis")
            $0.testCaseDidFinish(testClass: "TestCaseOne", method: "testThis", status: .passed, duration: 0.123)
            $0.testCaseDidStart(testClass: "TestCaseTwo", method: "testThat")
            $0.testCaseDidFinish(testClass: "TestCaseTwo", method: "testThat", status: .passed, duration: 0.456)
        }
        XCTAssertEqual(
            reporters.runtimeRecords,
            Set([TestRuntimeRecord(testName: "TestCaseOne/testThis", targetName: "UITests", runtime: 0.123),
                 TestRuntimeRecord(testName: "TestCaseOne/testThis", targetName: "UnitTests", runtime: 0.123),
                 TestRuntimeRecord(testName: "TestCaseTwo/testThat", targetName: "UITests", runtime: 0.456),
                 TestRuntimeRecord(testName: "TestCaseTwo/testThat", targetName: "UnitTests", runtime: 0.456)])
        )
    }

}
