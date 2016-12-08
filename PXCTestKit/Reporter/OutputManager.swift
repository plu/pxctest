//
//  OutputManager.swift
//  pxctest
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class OutputManager {

    var logFile: URL {
        return url.appendingPathComponent("simulator.log")
    }

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func createLogFile() throws -> FileHandle {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        if fileManager.fileExists(atPath: logFile.path) {
            try fileManager.removeItem(at: logFile)
        }

        fileManager.createFile(atPath: logFile.path, contents: nil, attributes: nil)

        return try FileHandle(forWritingTo: logFile)
    }

    func extractDiagnostics(simulators: [FBSimulator], testRun: FBXCTestRun, testErrors: [RunTestsCommand.TestError]) throws {
        for simulator in simulators {
            for target in testRun.targets {
                for application in target.applications {
                    guard let diagnostics = simulator.diagnostics.launchedProcessLogs().first(where: { $0.0.processName == application.name })?.value else { continue }
                    let destinationPath = urlFor(simulatorConfiguration: simulator.configuration!, target: target.name).path
                    try diagnostics.writeOut(toDirectory: destinationPath)
                }
            }
        }
        for error in testErrors {
            for crash in error.crashes {
                let destinationPath = urlFor(simulatorConfiguration: error.simulator.configuration!, target: error.target).path
                try crash.writeOut(toDirectory: destinationPath)
            }
        }
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

}
