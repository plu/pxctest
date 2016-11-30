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

    let testsToRun: Set<String>
    let targetName: String

    var description: String {
        return testsToRun.description
    }

    init(targetName: String, testsToRun: Set<String>) {
        self.targetName = targetName
        self.testsToRun = testsToRun
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            var parts = value.components(separatedBy: ":")
            guard let tests = parts.popLast(), let targetName = parts.popLast(), parts.count == 0 else {
                throw ArgumentError.invalidType(value: value, type: "only", argument: nil)
            }
            self.init(targetName: targetName, testsToRun: Set<String>(tests.components(separatedBy: ",")))
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

}
