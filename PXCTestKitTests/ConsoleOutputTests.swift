//
//  ConsoleOutputTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 9/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class ConsoleOutputTests: XCTestCase {

    private var console: ConsoleOutput!
    private var outputPath: String!

    enum Barf: Error, CustomStringConvertible {
        case loud

        var description: String {
            return "WUFF!"
        }
    }

    override func setUp() {
        super.setUp()

        outputPath = "\(NSTemporaryDirectory())/\(UUID().uuidString)"
        FileManager.default.createFile(atPath: outputPath, contents: nil, attributes: nil)
        let fileHandle = FileHandle(forWritingAtPath: outputPath)!
        console = ConsoleOutput(outputHandle: fileHandle, errorFileHandle: fileHandle)
    }

    func testWritingOutput() {
        console.write(output: ".F.F.F")
        console.write(line: "foo bar")
        console.write(output: "F.F.F.")
        console.write(error: Barf.loud)
        console.write(line: "bla fasel")
        console.write(error: Barf.loud)
        console.write(error: Barf.loud)
        XCTAssertContentOfFileAtPath(outputPath, [
            ".F.F.F",
            "foo bar",
            "F.F.F.",
            "WUFF!",
            "bla fasel",
            "WUFF!",
            "WUFF!",
            "",
        ].joined(separator: "\n"))
    }

}
