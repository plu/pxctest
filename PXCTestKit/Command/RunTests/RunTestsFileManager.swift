//
//  RunTestsFileManager.swift
//  pxctest
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsFileManager {

    let url: URL
    let fileManager: FileManager

    init(url: URL, fileManager: FileManager = FileManager.default) {
        self.url = url
        self.fileManager = fileManager
    }

    func createDirectoryFor(simulatorConfiguration: FBSimulatorConfiguration, target: String) throws {
        let url = urlFor(simulatorConfiguration: simulatorConfiguration, target: target)
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func urlFor(simulatorConfiguration: FBSimulatorConfiguration, target: String) -> URL {
        return url
            .appendingPathComponent(target)
            .appendingPathComponent(simulatorConfiguration.osVersionString)
            .appendingPathComponent(simulatorConfiguration.deviceName)
    }

    func urlFor(worker: RunTestsWorker) -> URL {
        return urlFor(simulatorConfiguration: worker.configuration, target: worker.name)
    }

}
