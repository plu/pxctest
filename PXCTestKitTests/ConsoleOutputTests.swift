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

    private var consoleOutput: ConsoleOutput!
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
        consoleOutput = ConsoleOutput(outputFileHandle: fileHandle, errorFileHandle: fileHandle)
    }

    func testWritingOutput() {
        consoleOutput.write(output: ".F.F.F")
        consoleOutput.write(line: "foo bar")
        consoleOutput.write(output: "F.F.F.")
        consoleOutput.write(error: Barf.loud)
        consoleOutput.write(line: "bla fasel")
        consoleOutput.write(error: Barf.loud)
        consoleOutput.write(error: Barf.loud)
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
