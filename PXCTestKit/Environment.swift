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
    private static let insertLibrariesKey = "DYLD_INSERT_LIBRARIES"

    static func injectPrefixedVariables(from source: [String: String], into destination: [String: String]?, workingDirectoryURL: URL) -> [String: String] {
        var result = destination ?? [:]
        for (key, value) in source {
            if !key.hasPrefix(prefix) {
                continue
            }
            result[key.replacingOccurrences(of: prefix, with: "")] = value
        }
        ["IMAGE_DIFF_DIR", "KIF_SCREENSHOTS"].forEach { result[$0] = workingDirectoryURL.path }
        return result
    }

    static func injectLibrary(atPath libraryPath: String, into environment: [String: String]?) -> [String: String] {
        var result = environment ?? [:]
        var insertLibraries = (result[insertLibrariesKey] ?? "").components(separatedBy: ":").filter { $0.characters.count > 0 }
        insertLibraries.append(libraryPath)
        result[insertLibrariesKey] = insertLibraries.joined(separator: ":")
        return result
    }

}
