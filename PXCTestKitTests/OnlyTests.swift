//
//  OnlyTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 01/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class OnlyTests: XCTestCase {

    func testParsingValidFormat() throws {
        let only = try Only(string: "TestTarget:ClassOne/testThis,ClassTwo/testThat")
        XCTAssertEqual(only.targetName, "TestTarget")
        XCTAssertEqual(only.testsToRun, Set(["ClassOne/testThis", "ClassTwo/testThat"]))
    }

    func testParsingInvalidFormat() throws {
        XCTAssertThrowsError(try Only(string: "ClassOne/testThis,ClassTwo/testThat"))
    }

}
