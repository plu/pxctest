//
//  SimulatorLogFile.swift
//  pxctest
//
//  Created by Johannes Plunien on 14/1/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

final class SimulatorLogFile {

    let fileHandle: FileHandle
    let url: URL

    init(url: URL) throws {
        self.url = url
        self.fileHandle = try SimulatorLogFile.createLogFile(atURL: url)
    }

    deinit {
        fileHandle.synchronizeFile()
        fileHandle.closeFile()
    }

    // MARK: - Private

    private static let fileManager = FileManager.default

    private static func createLogFile(atURL url: URL) throws -> FileHandle {
        try createDirectory(forLogFileAtURL: url)
        if !fileManager.fileExists(atPath: url.path) {
            fileManager.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        let fileHandle = try FileHandle(forWritingTo: url)
        fileHandle.seekToEndOfFile()
        return fileHandle
    }

    private static func createDirectory(forLogFileAtURL url: URL) throws {
        let directoryURL = url.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }

}
