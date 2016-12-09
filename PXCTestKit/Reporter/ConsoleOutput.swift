//
//  ConsoleOutput.swift
//  pxctest
//
//  Created by Johannes Plunien on 27/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

final class ConsoleOutput {

    private let outputFileHandle: FileHandle
    private let errorFileHandle: FileHandle
    private var lastOutputContainedNewLine = false

    init(outputHandle: FileHandle = FileHandle.standardOutput, errorFileHandle: FileHandle = FileHandle.standardError) {
        self.outputFileHandle = outputHandle
        self.errorFileHandle = outputHandle
    }

    func write(line: String) {
        let output = lastOutputContainedNewLine ? "\(line)\n" : "\n\(line)\n"
        outputFileHandle.write(output.data(using: .utf8)!)
        lastOutputContainedNewLine = true
    }

    func write(output: String) {
        lastOutputContainedNewLine = false
        outputFileHandle.write(output.data(using: .utf8)!)
    }

    func write(error: Error) {
        let formattedError = ConsoleErrorFormatter.format(error: error)
        let output = lastOutputContainedNewLine ? "\(formattedError)\n" : "\n\(formattedError)\n"
        errorFileHandle.write(output.data(using: .utf8)!)
        lastOutputContainedNewLine = true
    }

}
