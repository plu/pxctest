//
//  Reporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

enum Reporter: ArgumentConvertible {

    case json, rspec

    var description: String {
        switch self {
        case .json:  return "\(JSONReporter.self)"
        case .rspec: return "\(RSpecReporter.self)"
        }
    }

    var type: ConsoleReporter.Type {
        switch self {
        case .json:  return JSONReporter.self
        case .rspec: return RSpecReporter.self
        }
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            switch value {
            case "json": self = .json
            case "rspec": self = .rspec
            default: throw ArgumentError.invalidType(value: value, type: "reporter", argument: nil)
            }
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

}
