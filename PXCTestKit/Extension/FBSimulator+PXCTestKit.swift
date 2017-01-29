//
//  FBSimulator+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 04/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

extension FBSimulator {

    var identifier: String {
        return "\(configuration!.deviceName) \(configuration!.osVersionString)"
    }

    func install(applications: [FBApplicationDescriptor]) throws {
        for application in applications {
            try interact.installApplication(application).perform()
        }
    }

}

extension Sequence where Iterator.Element == FBApplicationDescriptor {

    func contains(bundleID: String) -> Bool {
        return filter { $0.bundleID == bundleID }.count == 1
    }

}
