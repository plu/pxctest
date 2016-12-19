//
//  Environment.swift
//  pxctest
//
//  Created by Johannes Plunien on 28/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

final class Environment {

    private static let prefix = "PXCTEST_CHILD_"
    private static let fileManager = FileManager.default
    private static let insertLibrariesKey = "DYLD_INSERT_LIBRARIES"
    private static let listTestsShimName = "libpxctest-list-tests.dylib"

    static func prepare(forRunningTests environmentVariables: [String: String]?, with otherEnvironmentVariables: [String: String]) -> [String: String] {
        var result = environmentVariables ?? [:]
        for (key, value) in otherEnvironmentVariables {
            if !key.hasPrefix(prefix) {
                continue
            }
            result[key.replacingOccurrences(of: prefix, with: "")] = value
        }
        return result
    }

    static func prepare(forListingTests environmentVariables: [String: String]?) throws -> [String: String] {
        var result = environmentVariables ?? [:]
        let insertLibraries = result[insertLibrariesKey] ?? ""
        let listTestsShimPath = URL(fileURLWithPath: Bundle(for: self).bundlePath)
            .deletingLastPathComponent()
            .appendingPathComponent(listTestsShimName)
            .path
        assert(fileManager.fileExists(atPath: listTestsShimPath))
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(listTestsShimName).path
        if !fileManager.fileExists(atPath: destinationPath) {
            try fileManager.copyItem(atPath: listTestsShimPath, toPath: destinationPath)
        }
        result[insertLibrariesKey] = [destinationPath, insertLibraries].joined(separator: ":")
        return result
    }

}
