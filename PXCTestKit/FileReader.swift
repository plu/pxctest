//
//  FileReader.swift
//  pxctest
//
//  Created by Johannes Plunien on 20/02/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

final class FileReader {

    private var buffer: Data
    private let chunkSize: Int
    private let encoding: String.Encoding
    private var eof: Bool
    private var fileHandle: FileHandle?
    private let delimiter: Data

    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
        guard
            let fileHandle = FileHandle(forReadingAtPath: path),
            let delimiter = delimiter.data(using: encoding)
        else { return nil }

        self.buffer = Data(capacity: chunkSize)
        self.chunkSize = chunkSize
        self.delimiter = delimiter
        self.encoding = encoding
        self.eof = false
        self.fileHandle = fileHandle
    }

    deinit {
        fileHandle?.closeFile()
        fileHandle = nil
    }

    func nextLine() -> String? {
        guard let fileHandle = fileHandle else {
            return nil
        }

        while !eof {
            if let range = buffer.range(of: delimiter) {
                let line = String(data: buffer.subdata(in: 0..<range.upperBound), encoding: encoding)
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                eof = true
                if buffer.count > 0 {
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }

}

extension FileReader: Sequence {

    func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }

}
