//
//  FileWriter.swift
//  pxctest
//
//  Created by Johannes Plunien on 20/02/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

final class FileWriter {

    private let encoding: String.Encoding
    private var fileHandle: FileHandle?

    init?(path: String, encoding: String.Encoding = .utf8) {
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)

        guard let fileHandle = FileHandle(forWritingAtPath: path) else { return nil }

        self.encoding = encoding
        self.fileHandle = fileHandle
    }

    deinit {
        fileHandle?.closeFile()
        fileHandle = nil
    }

    func write(string: String) {
        guard let data = string.data(using: encoding) else { return }
        fileHandle?.write(data)
    }

}
