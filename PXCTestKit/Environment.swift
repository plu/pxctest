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

    static func prepare(forListingTests environmentVariables: [String: String]?) -> [String: String] {
        var result = environmentVariables ?? [:]
        let insertLibraries = result["DYLD_INSERT_LIBRARIES"] ?? ""
        let listTestsShim = URL(fileURLWithPath: Bundle(for: self).bundlePath)
            .deletingLastPathComponent()
            .appendingPathComponent("libpxctest-list-tests.dylib")
        assert(FileManager.default.fileExists(atPath: listTestsShim.path))
        result["DYLD_INSERT_LIBRARIES"] = [listTestsShim.path, insertLibraries].joined(separator: ":")
        return result
    }

}
