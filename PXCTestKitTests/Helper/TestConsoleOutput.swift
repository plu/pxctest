//
//  TestConsoleOutput.swift
//  pxctest
//
//  Created by Johannes Plunien on 18/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation
@testable import PXCTestKit

final class TestConsoleOutput {

    let consoleOutput: ConsoleOutput

    private let temporaryDirectory: URL
    private let outputFileHandle: FileHandle
    private let outputFilePath: String
    private let errorFileHandle: FileHandle
    private let errorFilePath: String

    init() throws {
        temporaryDirectory = try fixtures.createNewTemporaryDirectory()
        outputFilePath = temporaryDirectory.appendingPathComponent("stdout.log").path
        errorFilePath = temporaryDirectory.appendingPathComponent("stderr.log").path
        FileManager.default.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: errorFilePath, contents: nil, attributes: nil)
        outputFileHandle = FileHandle(forWritingAtPath: outputFilePath)!
        errorFileHandle = FileHandle(forWritingAtPath: errorFilePath)!
        consoleOutput = ConsoleOutput(outputFileHandle: outputFileHandle, errorFileHandle: errorFileHandle)
    }

    func standardOutput() throws -> String {
        return try String(contentsOfFile: outputFilePath)
    }

    func errorOutput() throws -> String {
        return try String(contentsOfFile: errorFilePath)
    }

}
