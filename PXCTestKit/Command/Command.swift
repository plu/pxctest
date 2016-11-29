//
//  Command.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

protocol Command {

    func abort()
    func run() throws

}
