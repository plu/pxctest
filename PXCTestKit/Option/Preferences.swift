//
//  Preferences.swift
//  pxctest
//
//  Created by Johannes Plunien on 24/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation

/*
 * Loads some JSON from a file containing a dictionary of optians that will
 * be written to a Simulator's Library/Preferences/com.apple.Preferences.plist
 * property list file. Example:
 *
 * {
 *   "KeyboardAllowPaddle": false,
 *   "KeyboardAssistant": false,
 *   "KeyboardAutocapitalization": false,
 *   "KeyboardAutocorrection": false,
 *   "KeyboardCapsLock": false,
 *   "KeyboardCheckSpelling": false,
 *   "KeyboardPeriodShortcut": false,
 *   "KeyboardPrediction": false,
 *   "KeyboardShowPredictionBar": false
 * }
 *
 * This content will disable all the on/off keyboard helpers you can find in the
 * Simulator's Settings app.
 */

struct Preferences: ArgumentConvertible {

    let dictionary: [String: Any]

    var description: String {
        return dictionary.description
    }

    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    init() {
        self.init(dictionary: [:])
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            let data = try Data(contentsOf: URL(fileURLWithPath: value))
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                self.init(dictionary: dictionary)
            }
            else {
                throw ArgumentError.invalidType(value: value, type: "preferences", argument: nil)
            }
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

}
