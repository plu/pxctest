//
//  RunTestsOutputManager.swift
//  pxctest
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsOutputManager {

    var logFile: URL {
        return url.appendingPathComponent("simulator.log")
    }

    let url: URL

    private var logFileHandle: FileHandle? = nil

    init(url: URL) {
        self.url = url
    }

    deinit {
        logFileHandle?.synchronizeFile()
        logFileHandle?.closeFile()
    }

    func createNewSimulatorLogFile() throws -> FileHandle {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        if fileManager.fileExists(atPath: logFile.path) {
            try fileManager.removeItem(at: logFile)
        }

        fileManager.createFile(atPath: logFile.path, contents: nil, attributes: nil)

        logFileHandle = try FileHandle(forWritingTo: logFile)

        return logFileHandle!
    }

    func reset(targets: [String], simulatorConfigurations: [FBSimulatorConfiguration]) throws {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        for target in targets {
            for simulatorConfiguration in simulatorConfigurations {
                let targetSimulatorURL = urlFor(simulatorConfiguration: simulatorConfiguration, target: target)
                if fileManager.fileExists(atPath: targetSimulatorURL.path) {
                    try fileManager.removeItem(at: targetSimulatorURL)
                }
                try fileManager.createDirectory(at: targetSimulatorURL, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }

    func urlFor(simulatorConfiguration: FBSimulatorConfiguration, target: String) -> URL {
        return url
            .appendingPathComponent(target)
            .appendingPathComponent(simulatorConfiguration.osVersionString)
            .appendingPathComponent(simulatorConfiguration.deviceName)
    }

    func urlFor(worker: RunTestsWorker) -> URL {
        return urlFor(simulatorConfiguration: worker.configuration, target: worker.target.name)
    }

}
