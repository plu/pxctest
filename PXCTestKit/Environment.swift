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

    static func prepare(_ environmentVariables: [String: String]?, with otherEnvironmentVariables: [String: String]) -> [String: String] {
        var result = environmentVariables ?? [:]
        result["OS_ACTIVITY_MODE"] = "disable"
        for (key, value) in otherEnvironmentVariables {
            if !key.hasPrefix(prefix) {
                continue
            }
            result[key.replacingOccurrences(of: prefix, with: "")] = value
        }
        return result
    }

}
