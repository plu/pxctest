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

    let cacheURL: URL
    let fileManager: FileManager
    let outputURL: URL
    let runtimeCacheURL: URL

    init(outputURL: URL, testRunURL: URL, fileManager: FileManager = FileManager.default) throws {
        self.outputURL = outputURL
        self.fileManager = fileManager
        self.cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("pxctest")
        self.runtimeCacheURL = self.cacheURL.appendingPathComponent("\(testRunURL.path.sha256!).runtime").appendingPathExtension("json")
        try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
    }

    func createDirectoryFor(simulatorConfiguration: FBSimulatorConfiguration, target: String) throws {
        let url = urlFor(simulatorConfiguration: simulatorConfiguration, target: target)
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func urlFor(simulatorConfiguration: FBSimulatorConfiguration, target: String) -> URL {
        return outputURL
            .appendingPathComponent(target)
            .appendingPathComponent(simulatorConfiguration.osVersionString)
            .appendingPathComponent(simulatorConfiguration.deviceName)
    }

    func urlFor(worker: RunTestsWorker) -> URL {
        return urlFor(simulatorConfiguration: worker.configuration, target: worker.name)
    }

}
