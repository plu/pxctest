//
//  ExistingFileURLOption.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

struct ExistingFileURLOption: ArgumentConvertible {

    let url: URL

    var description: String {
        return url.description
    }

    init(url: URL) {
        self.url = url
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            self.init(url: URL(fileURLWithPath: value))
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw ArgumentError.invalidType(value: value, type: "path", argument: nil)
            }
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

}
