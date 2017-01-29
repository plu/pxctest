//
//  RunTestsPartitionTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 26/01/17.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class RunTestsPartitionTests: XCTestCase {

    func testSplit() {
        let tests = Set([Int](1...51).map { "TestCase/testMethod\($0)" })
        let partition = RunTestsPartition(fileURL: fixtures.testRuntimeInput, partitions: 4, targetName: "UITests")
        let splitTests = partition.split(tests: tests)

        XCTAssertEqual(splitTests[0][0].testName, "TestCase/testMethod12")
        XCTAssertEqual(splitTests[1][0].testName, "TestCase/testMethod44")
        XCTAssertEqual(splitTests[2][0].testName, "TestCase/testMethod51")
        XCTAssertEqual(splitTests[3][0].testName, "TestCase/testMethod45")

        XCTAssertEqual(splitTests[0][1].testName, "TestCase/testMethod4")
        XCTAssertEqual(splitTests[1][1].testName, "TestCase/testMethod29")
        XCTAssertEqual(splitTests[2][1].testName, "TestCase/testMethod2")
        XCTAssertEqual(splitTests[3][1].testName, "TestCase/testMethod5")
    }

}
