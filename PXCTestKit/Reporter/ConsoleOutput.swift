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

    init(outputHandle: FileHandle = FileHandle.standardOutput, errorFileHandle: FileHandle = FileHandle.standardError) {
        self.outputFileHandle = outputHandle
        self.errorFileHandle = outputHandle
    }

    func write(line: String) {
        write(output: "\(line)\n")
    }

    func write(output: String) {
        outputFileHandle.write(output.data(using: .utf8)!)
    }

    func write(error: Error) {
        let output = String(format: "\n%@%@%@\n", ANSI.red.description, ConsoleErrorFormatter.format(error: error), ANSI.reset.description)
        errorFileHandle.write(output.data(using: .utf8)!)
    }

}
