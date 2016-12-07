//
//  OnlyOption.swift
//  pxctest
//
//  Created by Johannes Plunien on 24/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

struct OnlyOption: ArgumentConvertible {

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
        (self.targetName, self.testsToRun) = try OnlyOption.parse(string: string)
    }

    enum ParsingError: Error, CustomStringConvertible {
        case invalidFormat(String)
        case missingTarget(String)

        var description: String {
            switch self {
            case .invalidFormat(let only): return "Invalid only format: \(only)"
            case .missingTarget(let only): return "Invalid only format: \(only)"
            }
        }
    }

    static func parse(string: String) throws -> (String, Set<String>) {
        if string.contains(",") && !string.contains(":") {
            throw ParsingError.invalidFormat(string)
        }

        var tests = Set<String>()
        var parts = Array(string.components(separatedBy: ":").reversed())

        guard let targetName = parts.popLast() else {
            throw ParsingError.missingTarget(string)
        }

        if let testsString = parts.popLast() {
            testsString
                .components(separatedBy: ",")
                .filter { $0.characters.count > 0 }
                .forEach { tests.insert($0) }
        }

        if parts.count != 0 {
            throw ParsingError.invalidFormat(string)
        }

        return (targetName, tests)
    }

}


extension Sequence where Iterator.Element == OnlyOption {

    func dictionary() -> [String: Set<String>] {
        return reduce([String: Set<String>](), {
            var result = $0
            result[$1.targetName] = $1.testsToRun
            return result
        })
    }

}
