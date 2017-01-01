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
            if installedApplications.contains(bundleID: application.bundleID) {
                try interact.uninstallApplication(withBundleID: application.bundleID).perform()
            }
            try interact.installApplication(application).perform()
            if (!FBRunLoopSpinner().timeout(FBControlCoreGlobalConfiguration.fastTimeout()).spin { self.installedApplications.contains(bundleID: application.bundleID) }) {
                preconditionFailure("Installation of application failed")
            }
        }
    }

}

extension Sequence where Iterator.Element == FBApplicationDescriptor {

    func contains(bundleID: String) -> Bool {
        return filter { $0.bundleID == bundleID }.count == 1
    }

}
