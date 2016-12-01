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

    func testDictionary() throws {
        let dictionary = [
            try Only(string: "UITests:HomeScreen/testThis,SearchScreen/testThat"),
            try Only(string: "UnitTests:UserService/testThis,SearchService/testThat"),
        ].dictionary()
        XCTAssertEqual(dictionary, [
            "UnitTests": Set<String>(["UserService/testThis", "SearchService/testThat"]),
            "UITests": Set<String>(["HomeScreen/testThis", "SearchScreen/testThat"]),
        ])
    }

}
