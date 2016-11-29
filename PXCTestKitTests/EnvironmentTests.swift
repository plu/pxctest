//
//  EnvironmentTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 28/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class EnvironmentTests: XCTestCase {

    func testInjectsPrefixedVariables() {
        let environment = ["FOO": "BAR"]
        let processInfoEnvironment = ["PXCTEST_CHILD_BLA": "FASEL"]
        let result = Environment.prepare(environment, with: processInfoEnvironment)
        XCTAssertEqual(result, ["FOO": "BAR", "BLA": "FASEL", "OS_ACTIVITY_MODE": "disable"])
    }

}
