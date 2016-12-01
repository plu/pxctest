//
//  Only.swift
//  pxctest
//
//  Created by Johannes Plunien on 24/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

struct Only: ArgumentConvertible {

    let targetName: String
    let testsToRun: Set<String>

    private let testsToRunIdentifier: String

    var description: String {
        return "\(testsToRunIdentifier)"
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            try self.init(string: value)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

    init(string: String) throws {
        self.testsToRunIdentifier = string
        (self.targetName, self.testsToRun) = try Only.parse(string: string)
    }

    enum ParsingError: Error, CustomStringConvertible {
        case missingTarget(String)

        var description: String {
            switch self {
            case .missingTarget(let only): return "Invalid only format: \(only)"
            }
        }
    }

    static func parse(string: String) throws -> (String, Set<String>) {
        var parts = string.components(separatedBy: ":")
        guard let tests = parts.popLast(), let targetName = parts.popLast(), parts.count == 0 else {
            throw ParsingError.missingTarget(string)
        }
        return (targetName, Set<String>(tests.components(separatedBy: ",")))
    }

}


extension Sequence where Iterator.Element == Only {

    func dictionary() -> [String: Set<String>] {
        return reduce([String: Set<String>](), {
            var result = $0
            result[$1.targetName] = $1.testsToRun
            return result
        })
    }

}
