//
//  RunTestsError.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

struct RunTestsError {
    let simulator: FBSimulator
    let target: String
    let errors: [Error]
    let crashes: [FBDiagnostic]
}
