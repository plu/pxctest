//
//  Int+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 10/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

extension Int {

    func pluralized(_ string: String) -> String {
        return self == 1 ? "\(self) \(string)" : "\(self) \(string)s"
    }

}
