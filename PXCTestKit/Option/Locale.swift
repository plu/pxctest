//
//  Locale.swift
//  pxctest
//
//  Created by Johannes Plunien on 24/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

extension Locale: ArgumentConvertible {

    public init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            self.init(identifier: value)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

}
