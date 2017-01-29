//
//  ArrayExtensionTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/01/17.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class ArrayExtensionTests: XCTestCase {

    func testSplitIntoTwo() {
        var result = ["foo", "bar", "bla", "fasel", "last"].split(partitions: 2)
        var expected = [["foo", "bla", "last"], ["bar", "fasel"]]
        repeat {
            XCTAssertEqual(result.popLast()!, expected.popLast()!)
        } while result.count > 0 && expected.count > 0
    }

    func testSplitIntoThree() {
        var result = ["foo", "bar", "bla", "fasel", "last"].split(partitions: 3)
        var expected = [["foo", "fasel"], ["bar", "last"], ["bla"]]
        repeat {
            XCTAssertEqual(result.popLast()!, expected.popLast()!)
        } while result.count > 0 && expected.count > 0
    }

    func testSplitIntoTen() {
        var result = ["foo", "bar", "bla", "fasel", "last"].split(partitions: 10)
        var expected = [["foo"], ["bar"], ["bla"], ["fasel"], ["last"]]
        repeat {
            XCTAssertEqual(result.popLast()!, expected.popLast()!)
        } while result.count > 0 && expected.count > 0
    }

}
