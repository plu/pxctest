//
//  StringExtensionTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class StringExtensionTests: XCTestCase {

    func testSha256() {
        XCTAssertEqual("foo bar".sha256!, "fbc1a9f858ea9e177916964bd88c3d37b91a1e84412765e29950777f265c4b75")
    }

}
