//
//  ANSI.swift
//  pxctest
//
//  Created by Johannes Plunien on 08/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

enum ANSI: UInt8, CustomStringConvertible {

    static var disabled = false

    case reset = 0
    case bold

    case black = 30
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    case `default`

    var description: String {
        return ANSI.disabled ?  "" : "\u{001B}[\(self.rawValue)m"
    }

}
