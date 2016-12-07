//
//  OnlyOptionTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 01/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class OnlyOptionTests: XCTestCase {

    func testParsingValidFormat() throws {
        let only = try OnlyOption(string: "TestTarget:ClassOne/testThis,ClassTwo/testThat")
        XCTAssertEqual(only.targetName, "TestTarget")
        XCTAssertEqual(only.testsToRun, Set(["ClassOne/testThis", "ClassTwo/testThat"]))
    }

    func testParsingTargetOnlyOption() throws {
        let only = try OnlyOption(string: "TestTarget")
        XCTAssertEqual(only.targetName, "TestTarget")
        XCTAssertEqual(only.testsToRun, Set())
    }

    func testParsingTargetWithEmptyListOfTests() throws {
        let only = try OnlyOption(string: "TestTarget:")
        XCTAssertEqual(only.targetName, "TestTarget")
        XCTAssertEqual(only.testsToRun, Set())
    }

    func testParsingInvalidFormat() throws {
        XCTAssertThrowsError(try OnlyOption(string: "ClassOne/testThis,ClassTwo/testThat"))
        XCTAssertThrowsError(try OnlyOption(string: "FOO:BAR:BLA"))
    }

    func testDictionary() throws {
        let dictionary = [
            try OnlyOption(string: "UITests:HomeScreen/testThis,SearchScreen/testThat"),
            try OnlyOption(string: "UnitTests:UserService/testThis,SearchService/testThat"),
        ].dictionary()
        XCTAssertEqual(dictionary, [
            "UnitTests": Set<String>(["UserService/testThis", "SearchService/testThat"]),
            "UITests": Set<String>(["HomeScreen/testThis", "SearchScreen/testThat"]),
        ])
    }

}
