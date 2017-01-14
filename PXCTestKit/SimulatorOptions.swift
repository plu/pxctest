//
//  SimulatorOptions.swift
//  pxctest
//
//  Created by Johannes Plunien on 14/1/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

struct SimulatorOptions {

    let allocationOptions: FBSimulatorAllocationOptions
    let bootOptions: FBSimulatorBootOptions
    let managementOptions: FBSimulatorManagementOptions

}
