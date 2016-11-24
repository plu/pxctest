//
//  Only.swift
//  pxctest
//
//  Created by Plunien, Johannes(AWF) on 24/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

struct Only: ArgumentConvertible {

    let testsToRun: Set<String>

    var description: String {
        return testsToRun.description
    }

    init(testsToRun: Set<String>) {
        self.testsToRun = testsToRun
    }

    init() {
        self.init(testsToRun: Set<String>())
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            self.init(testsToRun: Set<String>(value.components(separatedBy: ",")))
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

}
