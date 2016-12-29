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

    func reinstall(applications: [FBApplicationDescriptor]) throws {
        for application in applications {
            if installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1 {
                try interact.uninstallApplication(withBundleID: application.bundleID).perform()
            }
            try interact.installApplication(application).perform()
            assert(installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1)
        }
    }

}
