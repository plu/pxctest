//
//  FileReaderTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 20/02/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class FileReaderTests: XCTestCase {

    func testNextLine() {
        var expectedLines = Array([
            "this\n",
            "is\n",
            "some\n",
            "text\n",
            "lastline\n",
        ].reversed())
        let reader = FileReader(path: fixtures.textFilePath)!
        for line in reader {
            XCTAssertEqual(line, expectedLines.popLast())
        }
    }

}
